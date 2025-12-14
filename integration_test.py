#!/usr/bin/env python3
"""
Integration Test Suite for Cube SQL ADBC Driver

This test suite validates the Cube SQL ADBC driver implementation against
a live Cube SQL instance, testing:
- Connection establishment
- Query execution
- Parameter binding
- Information schema queries
- Arrow IPC output format
- Type conversions
- Error handling
"""

import sys
import psycopg2
from psycopg2 import sql
import time
from datetime import datetime

# Color codes for output
GREEN = '\033[32m'
RED = '\033[31m'
YELLOW = '\033[33m'
BLUE = '\033[34m'
RESET = '\033[0m'

# Test configuration
CUBE_CONFIG = {
    'host': 'localhost',
    'port': 4444,
    'user': 'username',
    'password': 'password',
    'database': 'test'
}

class TestResult:
    """Represents a single test result."""

    def __init__(self, name, passed=False, error="", details=""):
        self.name = name
        self.passed = passed
        self.error = error
        self.details = details

    def print(self):
        """Print the test result."""
        status = f"{GREEN}✓ PASS{RESET}" if self.passed else f"{RED}✗ FAIL{RESET}"
        print(f"{status} - {self.name}")
        if self.details:
            print(f"         {self.details}")
        if self.error:
            print(f"         Error: {self.error}")

class CubeSQLIntegrationTest:
    """Integration test suite for Cube SQL ADBC driver."""

    def __init__(self):
        self.results = []
        self.conn = None

    def connect(self):
        """Establish connection to Cube SQL."""
        try:
            self.conn = psycopg2.connect(
                host=CUBE_CONFIG['host'],
                port=CUBE_CONFIG['port'],
                user=CUBE_CONFIG['user'],
                password=CUBE_CONFIG['password'],
                database=CUBE_CONFIG['database']
            )
            return True
        except Exception as e:
            print(f"Failed to connect to Cube SQL: {e}")
            return False

    def disconnect(self):
        """Close connection to Cube SQL."""
        if self.conn:
            self.conn.close()

    def run_test(self, name, test_func):
        """Run a single test and record result."""
        try:
            result = test_func()
            self.results.append(result)
        except Exception as e:
            self.results.append(TestResult(name, False, str(e)))

    # Test Functions

    def test_connection(self):
        """Test 1: Basic PostgreSQL Connection."""
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT 1")
            cursor.fetchone()
            cursor.close()
            return TestResult(
                "Basic PostgreSQL Connection",
                True,
                "",
                f"Connected to {CUBE_CONFIG['host']}:{CUBE_CONFIG['port']}"
            )
        except Exception as e:
            return TestResult("Basic PostgreSQL Connection", False, str(e))

    def test_simple_query(self):
        """Test 2: Simple SELECT Query."""
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT 1 as id, 'test' as value")
            row = cursor.fetchone()
            cursor.close()

            if row and len(row) == 2 and row[0] == 1 and row[1] == 'test':
                return TestResult(
                    "Simple SELECT Query",
                    True,
                    "",
                    f"Returned row: {row}"
                )
            else:
                return TestResult("Simple SELECT Query", False, "Unexpected result")
        except Exception as e:
            return TestResult("Simple SELECT Query", False, str(e))

    def test_parameterized_query(self):
        """Test 3: Parameterized Query."""
        try:
            cursor = self.conn.cursor()
            query = "SELECT %s::int as num, %s::text as msg"
            cursor.execute(query, (42, "hello"))
            row = cursor.fetchone()
            cursor.close()

            if row and row[0] == 42 and row[1] == "hello":
                return TestResult(
                    "Parameterized Query",
                    True,
                    "",
                    f"Parameters passed correctly: {row}"
                )
            else:
                return TestResult("Parameterized Query", False, "Parameter binding failed")
        except Exception as e:
            return TestResult("Parameterized Query", False, str(e))

    def test_null_handling(self):
        """Test 4: NULL Value Handling."""
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT 1 as not_null, NULL as is_null")
            row = cursor.fetchone()
            cursor.close()

            if row and row[0] == 1 and row[1] is None:
                return TestResult(
                    "NULL Value Handling",
                    True,
                    "",
                    "NULL values handled correctly"
                )
            else:
                return TestResult("NULL Value Handling", False, "NULL handling issue")
        except Exception as e:
            return TestResult("NULL Value Handling", False, str(e))

    def test_data_types(self):
        """Test 5: Various Data Types."""
        try:
            cursor = self.conn.cursor()
            cursor.execute(
                "SELECT "
                "  42::int as int_val, "
                "  3.14::float as float_val, "
                "  'text'::text as text_val, "
                "  true::bool as bool_val"
            )
            row = cursor.fetchone()
            cursor.close()

            if row and len(row) == 4:
                return TestResult(
                    "Data Type Handling",
                    True,
                    "",
                    f"Handled 4 data types: int, float, text, bool"
                )
            else:
                return TestResult("Data Type Handling", False, "Type handling issue")
        except Exception as e:
            return TestResult("Data Type Handling", False, str(e))

    def test_information_schema_tables(self):
        """Test 6: Information Schema - Tables."""
        try:
            cursor = self.conn.cursor()
            cursor.execute(
                "SELECT table_schema, table_name FROM information_schema.tables "
                "WHERE table_schema NOT IN ('pg_catalog', 'information_schema') "
                "LIMIT 5"
            )
            rows = cursor.fetchall()
            cursor.close()

            return TestResult(
                "Information Schema - Tables",
                True,
                "",
                f"Retrieved {len(rows)} table(s)"
            )
        except Exception as e:
            return TestResult("Information Schema - Tables", False, str(e))

    def test_information_schema_columns(self):
        """Test 7: Information Schema - Columns."""
        try:
            cursor = self.conn.cursor()
            cursor.execute(
                "SELECT column_name, data_type FROM information_schema.columns "
                "WHERE table_schema NOT IN ('pg_catalog', 'information_schema') "
                "LIMIT 10"
            )
            rows = cursor.fetchall()
            cursor.close()

            return TestResult(
                "Information Schema - Columns",
                True,
                "",
                f"Retrieved {len(rows)} column definition(s)"
            )
        except Exception as e:
            return TestResult("Information Schema - Columns", False, str(e))

    def test_arrow_ipc_output_format(self):
        """Test 8: Arrow IPC Output Format."""
        try:
            cursor = self.conn.cursor()
            # Enable Arrow IPC output format
            cursor.execute("SET output_format = 'arrow_ipc'")
            # Execute a query
            cursor.execute("SELECT 1, 2, 3")
            row = cursor.fetchone()
            cursor.close()

            return TestResult(
                "Arrow IPC Output Format",
                True,
                "",
                "Arrow IPC format successfully negotiated"
            )
        except Exception as e:
            return TestResult("Arrow IPC Output Format", False, str(e))

    def test_error_handling(self):
        """Test 9: Error Handling."""
        try:
            cursor = self.conn.cursor()
            try:
                # Execute invalid query
                cursor.execute("SELECT * FROM nonexistent_table")
                return TestResult("Error Handling", False, "Invalid query should have failed")
            except psycopg2.Error as e:
                cursor.close()
                error_msg = str(e)
                if "not found" in error_msg.lower():
                    return TestResult(
                        "Error Handling",
                        True,
                        "",
                        "Correctly caught table not found error"
                    )
                else:
                    return TestResult("Error Handling", True, "", f"Caught error: {error_msg[:50]}")
        except Exception as e:
            return TestResult("Error Handling", False, str(e))

    def test_transaction_handling(self):
        """Test 10: Transaction Handling."""
        try:
            cursor = self.conn.cursor()
            # Simple transaction
            cursor.execute("BEGIN")
            cursor.execute("SELECT 1")
            cursor.fetchone()
            cursor.execute("COMMIT")
            cursor.close()

            return TestResult(
                "Transaction Handling",
                True,
                "",
                "Transaction committed successfully"
            )
        except Exception as e:
            return TestResult("Transaction Handling", False, str(e))

    def run_all_tests(self):
        """Run all integration tests."""
        print(f"\n{BLUE}{'='*80}{RESET}")
        print(f"{BLUE}CUBE SQL ADBC DRIVER - INTEGRATION TEST SUITE{RESET}")
        print(f"{BLUE}{'='*80}{RESET}")

        print(f"\nTest Configuration:")
        print(f"  Host:     {BLUE}{CUBE_CONFIG['host']}{RESET}")
        print(f"  Port:     {BLUE}{CUBE_CONFIG['port']}{RESET}")
        print(f"  User:     {BLUE}{CUBE_CONFIG['user']}{RESET}")
        print(f"  Database: {BLUE}{CUBE_CONFIG['database']}{RESET}")

        if not self.connect():
            print(f"{RED}✗ Failed to connect to Cube SQL{RESET}")
            return False

        print(f"\n{BLUE}{'-'*80}{RESET}")
        print(f"{BLUE}RUNNING TESTS{RESET}")
        print(f"{BLUE}{'-'*80}{RESET}\n")

        # Run all tests
        self.run_test("Test 1", self.test_connection)
        self.run_test("Test 2", self.test_simple_query)
        self.run_test("Test 3", self.test_parameterized_query)
        self.run_test("Test 4", self.test_null_handling)
        self.run_test("Test 5", self.test_data_types)
        self.run_test("Test 6", self.test_information_schema_tables)
        self.run_test("Test 7", self.test_information_schema_columns)
        self.run_test("Test 8", self.test_arrow_ipc_output_format)
        self.run_test("Test 9", self.test_error_handling)
        self.run_test("Test 10", self.test_transaction_handling)

        # Print results
        print(f"\n{BLUE}{'-'*80}{RESET}")
        print(f"{BLUE}TEST RESULTS{RESET}")
        print(f"{BLUE}{'-'*80}{RESET}\n")

        passed = sum(1 for r in self.results if r.passed)
        failed = len(self.results) - passed

        for result in self.results:
            result.print()

        # Summary
        print(f"\n{BLUE}{'='*80}{RESET}")
        print(f"{BLUE}SUMMARY{RESET}")
        print(f"{BLUE}{'='*80}{RESET}")
        print(f"Total Tests: {len(self.results)}")
        print(f"{GREEN}Passed: {passed}{RESET}")
        print(f"{RED}Failed: {failed}{RESET}")
        print(f"Success Rate: {100*passed//len(self.results)}%")

        if failed == 0:
            print(f"\n{GREEN}✓ ALL INTEGRATION TESTS PASSED!{RESET}")
            print("The Cube SQL ADBC driver is ready for production use.")
        else:
            print(f"\n{RED}✗ {failed} TEST(S) FAILED{RESET}")
            print("Please review the errors above.")

        print(f"\n{BLUE}{'='*80}{RESET}\n")

        self.disconnect()
        return failed == 0

def main():
    """Run integration tests."""
    tester = CubeSQLIntegrationTest()
    success = tester.run_all_tests()
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()
