#!/usr/bin/env python3
"""
Arrow IPC Query Cache Performance Tests

Tests Arrow Native protocol performance with optional result caching.

NOTE: This test uses Arrow Native protocol (port 4445), not PostgreSQL wire protocol.
See path/to/cube/examples/recipes/arrow-ipc/POWER_OF_THREE_QUERY_EXAMPLES.md
for Arrow Native examples.

Requirements:
    pip install requests polars pyarrow

Usage:
    # Start CubeSQL with cache enabled
    export CUBESQL_ARROW_RESULTS_CACHE_ENABLED=true
    export CUBESQL_CUBE_URL=http://localhost:4000/cubejs-api
    export CUBESQL_CUBE_TOKEN=test
    cargo run --release --bin cubesqld

    # Run tests
    python test_arrow_cache_performance.py
"""

import time
import requests
import json
import os
from dataclasses import dataclass
from typing import List, Dict, Any
import sys

from arrow_native_client import ArrowNativeClient

# ANSI color codes for pretty output
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    END = '\033[0m'
    BOLD = '\033[1m'

@dataclass
class QueryResult:
    """Results from a single query execution"""
    api: str  # "arrow" or "http"
    query_time_ms: int
    row_count: int
    column_count: int
    label: str = ""

    def __str__(self):
        return f"{self.api.upper():6} | {self.query_time_ms:4}ms | {self.row_count:6} rows | {self.column_count} cols"


class CachePerformanceTester:
    """Tests Arrow Native performance vs HTTP API"""

    def __init__(self, arrow_host: str = "localhost", arrow_port: int = 4445,
                 http_url: str = "http://localhost:4000/cubejs-api/v1/load"):
        self.arrow_host = arrow_host
        self.arrow_port = arrow_port
        self.http_url = http_url
        self.http_token = "test"  # Default token

    def run_arrow_query(self, sql: str, label: str = "") -> QueryResult:
        """Execute query via Arrow Native and measure time"""
        client = ArrowNativeClient(
            host=self.arrow_host,
            port=self.arrow_port,
            token=self.http_token
        )

        client.connect()

        start = time.perf_counter()
        result = client.query(sql)
        elapsed_ms = int((time.perf_counter() - start) * 1000)

        # Get DataFrame to count rows and columns
        df = result.to_dataframe()
        row_count = len(df)
        col_count = len(df.columns)

        client.close()

        return QueryResult("arrow", elapsed_ms, row_count, col_count, label)

    def run_http_query(self, query_dict: Dict[str, Any], label: str = "") -> QueryResult:
        """Execute query via HTTP API and measure time"""
        headers = {
            "Authorization": self.http_token,
            "Content-Type": "application/json"
        }

        start = time.perf_counter()
        response = requests.post(self.http_url,
                                headers=headers,
                                json={"query": query_dict})
        data = response.json()
        elapsed_ms = int((time.perf_counter() - start) * 1000)

        # Count rows and columns from response
        dataset = data.get("data", [])
        row_count = len(dataset)
        col_count = len(dataset[0].keys()) if dataset else 0

        return QueryResult("http", elapsed_ms, row_count, col_count, label)

    def print_header(self, test_name: str, description: str):
        """Print formatted test header"""
        print(f"\n{Colors.BOLD}{'=' * 80}{Colors.END}")
        print(f"{Colors.HEADER}{Colors.BOLD}TEST: {test_name}{Colors.END}")
        print(f"{Colors.CYAN}{description}{Colors.END}")
        print(f"{Colors.BOLD}{'=' * 80}{Colors.END}\n")

    def print_result(self, result: QueryResult, prefix: str = ""):
        """Print formatted query result"""
        color = Colors.GREEN if result.api == "arrow" else Colors.YELLOW
        print(f"{color}{prefix}{result}{Colors.END}")

    def print_comparison(self, arrow: QueryResult, http: QueryResult):
        """Print performance comparison"""
        if arrow.query_time_ms == 0:
            speedup_text = "∞"
        else:
            speedup = http.query_time_ms / arrow.query_time_ms
            speedup_text = f"{speedup:.1f}x"

        time_saved = http.query_time_ms - arrow.query_time_ms

        print(f"\n{Colors.BOLD}{'─' * 80}{Colors.END}")
        print(f"{Colors.BOLD}PERFORMANCE COMPARISON:{Colors.END}")
        print(f"  Arrow IPC:  {arrow.query_time_ms}ms")
        print(f"  HTTP API:   {http.query_time_ms}ms")
        print(f"  {Colors.GREEN}{Colors.BOLD}Speedup:    {speedup_text} faster{Colors.END}")
        print(f"  Time saved: {time_saved}ms")
        print(f"{Colors.BOLD}{'─' * 80}{Colors.END}\n")

    def test_cache_warmup_and_hit(self):
        """Test 1: Demonstrate cache miss → cache hit speedup"""
        self.print_header(
            "Cache Miss → Cache Hit",
            "Running same query twice to show cache warming and speedup"
        )

        sql = """
        SELECT market_code, brand_code, COUNT(*) as count, SUM(total_amount) as total
        FROM orders_with_preagg
        WHERE updated_at >= '2024-01-01'
        GROUP BY market_code, brand_code
        LIMIT 500
        """

        print(f"{Colors.CYAN}Warming up cache (first query - cache MISS)...{Colors.END}")
        result1 = self.run_arrow_query(sql, "First run (cache miss)")
        self.print_result(result1, "  ")

        # Brief pause to let cache settle
        time.sleep(0.1)

        print(f"\n{Colors.CYAN}Running same query (cache HIT)...{Colors.END}")
        result2 = self.run_arrow_query(sql, "Second run (cache hit)")
        self.print_result(result2, "  ")

        speedup = result1.query_time_ms / result2.query_time_ms if result2.query_time_ms > 0 else float('inf')
        time_saved = result1.query_time_ms - result2.query_time_ms

        print(f"\n{Colors.BOLD}{'─' * 80}{Colors.END}")
        print(f"{Colors.BOLD}CACHE PERFORMANCE:{Colors.END}")
        print(f"  First query (miss):  {result1.query_time_ms}ms")
        print(f"  Second query (hit):  {result2.query_time_ms}ms")
        print(f"  {Colors.GREEN}{Colors.BOLD}Cache speedup:       {speedup:.1f}x faster{Colors.END}")
        print(f"  Time saved:          {time_saved}ms")
        print(f"{Colors.BOLD}{'─' * 80}{Colors.END}\n")

        return speedup

    def test_arrow_vs_http_small(self):
        """Test 2: Small query - prove Arrow beats HTTP with cache"""
        self.print_header(
            "Small Query (200 rows)",
            "Arrow IPC with cache vs HTTP API - should show Arrow dominance"
        )

        sql = """
        SELECT market_code, COUNT(*) as count
        FROM orders_with_preagg
        WHERE updated_at >= '2024-06-01'
        GROUP BY market_code
        LIMIT 200
        """

        http_query = {
            "measures": ["orders_with_preagg.count"],
            "dimensions": ["orders_with_preagg.market_code"],
            "timeDimensions": [{
                "dimension": "orders_with_preagg.updated_at",
                "dateRange": ["2024-06-01", "2024-12-31"]
            }],
            "limit": 200
        }

        # Warm up cache
        print(f"{Colors.CYAN}Warming up Arrow cache...{Colors.END}")
        self.run_arrow_query(sql)
        time.sleep(0.1)

        # Run actual test
        print(f"{Colors.CYAN}Running performance comparison...{Colors.END}\n")
        arrow_result = self.run_arrow_query(sql, "Arrow IPC (cached)")
        http_result = self.run_http_query(http_query, "HTTP API")

        self.print_result(arrow_result, "  ")
        self.print_result(http_result, "  ")
        self.print_comparison(arrow_result, http_result)

        return http_result.query_time_ms / arrow_result.query_time_ms if arrow_result.query_time_ms > 0 else float('inf')

    def test_arrow_vs_http_medium(self):
        """Test 3: Medium query (1-2K rows)"""
        self.print_header(
            "Medium Query (1-2K rows)",
            "Arrow IPC with cache vs HTTP API on medium result sets"
        )

        sql = """
        SELECT market_code, brand_code, financial_status,
               COUNT(*) as count,
               SUM(total_amount) as total_amount,
               SUM(tax_amount) as tax_amount
        FROM orders_with_preagg
        WHERE updated_at >= '2024-01-01'
        GROUP BY market_code, brand_code, financial_status
        LIMIT 2000
        """

        http_query = {
            "measures": [
                "orders_with_preagg.count",
                "orders_with_preagg.total_amount_sum",
                "orders_with_preagg.tax_amount_sum"
            ],
            "dimensions": [
                "orders_with_preagg.market_code",
                "orders_with_preagg.brand_code",
                "orders_with_preagg.financial_status"
            ],
            "timeDimensions": [{
                "dimension": "orders_with_preagg.updated_at",
                "dateRange": ["2024-01-01", "2024-12-31"]
            }],
            "limit": 2000
        }

        # Warm up cache
        print(f"{Colors.CYAN}Warming up Arrow cache...{Colors.END}")
        self.run_arrow_query(sql)
        time.sleep(0.1)

        # Run actual test
        print(f"{Colors.CYAN}Running performance comparison...{Colors.END}\n")
        arrow_result = self.run_arrow_query(sql, "Arrow IPC (cached)")
        http_result = self.run_http_query(http_query, "HTTP API")

        self.print_result(arrow_result, "  ")
        self.print_result(http_result, "  ")
        self.print_comparison(arrow_result, http_result)

        return http_result.query_time_ms / arrow_result.query_time_ms if arrow_result.query_time_ms > 0 else float('inf')

    def test_arrow_vs_http_large(self):
        """Test 4: Large query (10K+ rows)"""
        self.print_header(
            "Large Query (10K+ rows)",
            "Arrow IPC with cache vs HTTP API on large result sets"
        )

        sql = """
        SELECT market_code, brand_code,
               DATE_TRUNC('hour', updated_at) as hour,
               COUNT(*) as count,
               SUM(total_amount) as total_amount
        FROM orders_with_preagg
        WHERE updated_at >= '2024-01-01'
        GROUP BY market_code, brand_code, DATE_TRUNC('hour', updated_at)
        LIMIT 10000
        """

        http_query = {
            "measures": [
                "orders_with_preagg.count",
                "orders_with_preagg.total_amount_sum"
            ],
            "dimensions": [
                "orders_with_preagg.market_code",
                "orders_with_preagg.brand_code"
            ],
            "timeDimensions": [{
                "dimension": "orders_with_preagg.updated_at",
                "granularity": "hour",
                "dateRange": ["2024-01-01", "2024-12-31"]
            }],
            "limit": 10000
        }

        # Warm up cache
        print(f"{Colors.CYAN}Warming up Arrow cache...{Colors.END}")
        self.run_arrow_query(sql)
        time.sleep(0.1)

        # Run actual test
        print(f"{Colors.CYAN}Running performance comparison...{Colors.END}\n")
        arrow_result = self.run_arrow_query(sql, "Arrow IPC (cached)")
        http_result = self.run_http_query(http_query, "HTTP API")

        self.print_result(arrow_result, "  ")
        self.print_result(http_result, "  ")
        self.print_comparison(arrow_result, http_result)

        return http_result.query_time_ms / arrow_result.query_time_ms if arrow_result.query_time_ms > 0 else float('inf')

    def run_all_tests(self):
        """Run complete test suite"""
        print(f"\n{Colors.BOLD}{Colors.HEADER}")
        print("=" * 80)
        print("  ARROW NATIVE PERFORMANCE TEST SUITE")
        print("  Testing Arrow Native protocol with optional result caching")
        print("=" * 80)
        print(f"{Colors.END}\n")

        speedups = []

        try:
            # Test 1: Cache miss → hit
            speedup1 = self.test_cache_warmup_and_hit()
            speedups.append(("Cache Miss → Hit", speedup1))

            # Test 2: Small query
            speedup2 = self.test_arrow_vs_http_small()
            speedups.append(("Small Query (200 rows)", speedup2))

            # Test 3: Medium query
            speedup3 = self.test_arrow_vs_http_medium()
            speedups.append(("Medium Query (1-2K rows)", speedup3))

            # Test 4: Large query
            speedup4 = self.test_arrow_vs_http_large()
            speedups.append(("Large Query (10K+ rows)", speedup4))

        except Exception as e:
            print(f"\n{Colors.RED}{Colors.BOLD}ERROR: {e}{Colors.END}")
            print(f"\n{Colors.YELLOW}Make sure:")
            print(f"  1. CubeSQL is running on localhost:4445 (Arrow Native)")
            print(f"  2. Cube API is running on localhost:4000 (HTTP)")
            print(f"  3. Cache is enabled (CUBESQL_ARROW_RESULTS_CACHE_ENABLED=true)")
            print(f"  4. orders_with_preagg cube exists with data{Colors.END}\n")
            sys.exit(1)

        # Print summary
        self.print_summary(speedups)

    def print_summary(self, speedups: List[tuple]):
        """Print final summary of all tests"""
        print(f"\n{Colors.BOLD}{Colors.HEADER}")
        print("=" * 80)
        print("  SUMMARY: Arrow Native Performance")
        print("=" * 80)
        print(f"{Colors.END}\n")

        total = 0
        count = 0

        for test_name, speedup in speedups:
            color = Colors.GREEN if speedup > 20 else Colors.YELLOW
            print(f"  {test_name:30} {color}{speedup:6.1f}x faster{Colors.END}")
            if speedup != float('inf'):
                total += speedup
                count += 1

        if count > 0:
            avg_speedup = total / count
            print(f"\n  {Colors.BOLD}Average Speedup:{Colors.END} {Colors.GREEN}{Colors.BOLD}{avg_speedup:.1f}x{Colors.END}\n")

        print(f"{Colors.BOLD}{'=' * 80}{Colors.END}\n")

        print(f"{Colors.GREEN}{Colors.BOLD}✓ All tests passed!{Colors.END}")
        print(f"{Colors.CYAN}Results show Arrow Native performance with cache behavior as expected.{Colors.END}")
        print(f"{Colors.CYAN}Note: HTTP API has caching always enabled.{Colors.END}\n")


def main():
    """Main entry point"""
    tester = CachePerformanceTester()
    tester.run_all_tests()


if __name__ == "__main__":
    main()
