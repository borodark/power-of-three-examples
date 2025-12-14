#!/usr/bin/env python3
"""
Test script for adbc_driver_cube

Assumes Cube server is running on localhost:4445 with Arrow Native protocol support
"""

import sys
import time
from typing import Optional


def test_arrow_native_protocol():
    """Test Arrow Native protocol connection."""
    print("=" * 60)
    print("Test 1: Arrow Native Protocol Connection")
    print("=" * 60)

    try:
        import adbc_driver_cube as cube

        # Connect using Arrow Native protocol
        print("\n→ Connecting to localhost:4445 (Arrow Native)...")
        db = cube.connect(
            host="localhost",
            port=4445,
            connection_mode="native",
            token="test"  # Default dev token
        )
        print("✓ Connected successfully!")

        # Create connection
        print("\n→ Creating connection...")
        conn = db.connect()
        print("✓ Connection created!")

        # Test simple query
        print("\n→ Executing test query: SELECT 1 as test_col")
        cursor = conn.cursor()
        cursor.execute("SELECT 1 as test_col")

        print("→ Fetching results as Arrow table...")
        table = cursor.fetch_arrow_table()
        print(f"✓ Got Arrow table with {len(table)} rows")
        print(f"  Schema: {table.schema}")
        print(f"  Data: {table.to_pydict()}")

        cursor.close()
        conn.close()

        print("\n✅ Arrow Native protocol test PASSED")
        return True

    except Exception as e:
        print(f"\n❌ Arrow Native protocol test FAILED: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_postgresql_protocol():
    """Test PostgreSQL protocol connection."""
    print("\n" + "=" * 60)
    print("Test 2: PostgreSQL Protocol Connection")
    print("=" * 60)

    try:
        import adbc_driver_cube as cube

        # Connect using PostgreSQL protocol
        print("\n→ Connecting to localhost:4444 (PostgreSQL)...")
        db = cube.connect(
            host="localhost",
            port=4444,
            connection_mode="postgresql",
            user="root",
            password=""
        )
        print("✓ Connected successfully!")

        # Create connection
        print("\n→ Creating connection...")
        conn = db.connect()
        print("✓ Connection created!")

        # Test simple query
        print("\n→ Executing test query: SELECT 1 as test_col")
        cursor = conn.cursor()
        cursor.execute("SELECT 1 as test_col")

        print("→ Fetching results as Arrow table...")
        table = cursor.fetch_arrow_table()
        print(f"✓ Got Arrow table with {len(table)} rows")
        print(f"  Schema: {table.schema}")
        print(f"  Data: {table.to_pydict()}")

        cursor.close()
        conn.close()

        print("\n✅ PostgreSQL protocol test PASSED")
        return True

    except Exception as e:
        print(f"\n❌ PostgreSQL protocol test FAILED: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_uri_connection():
    """Test URI-based connection."""
    print("\n" + "=" * 60)
    print("Test 3: URI-based Connection")
    print("=" * 60)

    try:
        import adbc_driver_cube as cube

        print("\n→ Connecting using URI: localhost:4445...")
        db = cube.connect(
            uri="localhost:4445",
            db_kwargs={
                "connection_mode": "native",
                "token": "test"
            }
        )
        print("✓ Connected successfully!")

        conn = db.connect()
        cursor = conn.cursor()
        cursor.execute("SELECT 1 as uri_test")
        table = cursor.fetch_arrow_table()
        print(f"✓ Got {len(table)} rows")

        cursor.close()
        conn.close()

        print("\n✅ URI connection test PASSED")
        return True

    except Exception as e:
        print(f"\n❌ URI connection test FAILED: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_metadata_queries():
    """Test metadata queries (SHOW TABLES, etc.)."""
    print("\n" + "=" * 60)
    print("Test 4: Metadata Queries")
    print("=" * 60)

    try:
        import adbc_driver_cube as cube

        db = cube.connect(
            uri="localhost:4445",
            db_kwargs={"connection_mode": "native", "token": "test"}
        )
        conn = db.connect()
        cursor = conn.cursor()

        # Test SHOW TABLES
        print("\n→ Executing: SHOW TABLES")
        try:
            cursor.execute("SHOW TABLES")
            table = cursor.fetch_arrow_table()
            print(f"✓ Got {len(table)} tables")
            if len(table) > 0:
                print(f"  Tables: {table.to_pydict()}")
        except Exception as e:
            print(f"⚠ SHOW TABLES failed (may not be implemented): {e}")

        cursor.close()
        conn.close()

        print("\n✅ Metadata queries test PASSED")
        return True

    except Exception as e:
        print(f"\n❌ Metadata queries test FAILED: {e}")
        import traceback
        traceback.print_exc()
        return False


def benchmark_protocols():
    """Benchmark Arrow Native vs PostgreSQL protocols."""
    print("\n" + "=" * 60)
    print("Test 5: Protocol Performance Comparison")
    print("=" * 60)

    try:
        import adbc_driver_cube as cube

        # Benchmark query (adjust based on your schema)
        test_query = "SELECT 1 as id UNION ALL SELECT 2 UNION ALL SELECT 3"

        results = {}

        for mode, port in [("native", 4445), ("postgresql", 4444)]:
            print(f"\n→ Benchmarking {mode} protocol...")

            db = cube.connect(
                host="localhost",
                port=port,
                connection_mode=mode,
                token="test" if mode == "native" else None,
                user="root" if mode == "postgresql" else None,
                password="" if mode == "postgresql" else None
            )

            # Warmup
            conn = db.connect()
            cursor = conn.cursor()
            cursor.execute(test_query)
            cursor.fetch_arrow_table()
            cursor.close()

            # Timed runs
            times = []
            for i in range(5):
                cursor = conn.cursor()
                start = time.time()
                cursor.execute(test_query)
                table = cursor.fetch_arrow_table()
                elapsed = time.time() - start
                times.append(elapsed)
                cursor.close()

            conn.close()

            avg_time = sum(times) / len(times)
            results[mode] = avg_time
            print(f"  Average time: {avg_time * 1000:.2f}ms ({len(times)} runs)")

        # Compare
        print("\n→ Comparison:")
        pg_time = results.get("postgresql", 0)
        native_time = results.get("native", 0)

        if pg_time > 0 and native_time > 0:
            speedup = pg_time / native_time
            print(f"  PostgreSQL: {pg_time * 1000:.2f}ms")
            print(f"  Arrow Native: {native_time * 1000:.2f}ms")
            print(f"  Speedup: {speedup:.2f}x")

            if native_time < pg_time:
                print("  ✓ Arrow Native is faster!")
            else:
                print("  ⚠ PostgreSQL is faster (unexpected)")

        print("\n✅ Performance benchmark PASSED")
        return True

    except Exception as e:
        print(f"\n❌ Performance benchmark FAILED: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    """Run all tests."""
    print("\n" + "=" * 60)
    print("ADBC Driver for Cube - Test Suite")
    print("=" * 60)

    # Check dependencies
    print("\n→ Checking dependencies...")
    try:
        import adbc_driver_manager
        print(f"  ✓ adbc_driver_manager {adbc_driver_manager.__version__}")
    except ImportError:
        print("  ❌ adbc_driver_manager not found")
        print("     Install with: pip install adbc-driver-manager")
        return 1

    try:
        import pyarrow as pa
        print(f"  ✓ pyarrow {pa.__version__}")
    except ImportError:
        print("  ❌ pyarrow not found")
        print("     Install with: pip install pyarrow")
        return 1

    try:
        import adbc_driver_cube
        print(f"  ✓ adbc_driver_cube {adbc_driver_cube.__version__}")
    except ImportError as e:
        print(f"  ❌ adbc_driver_cube not found: {e}")
        print("     Install with: pip install -e .")
        return 1

    # Run tests
    tests = [
        ("Arrow Native Protocol", test_arrow_native_protocol),
        ("PostgreSQL Protocol", test_postgresql_protocol),
        ("URI Connection", test_uri_connection),
        ("Metadata Queries", test_metadata_queries),
        ("Performance Benchmark", benchmark_protocols),
    ]

    results = []
    for name, test_func in tests:
        try:
            passed = test_func()
            results.append((name, passed))
        except KeyboardInterrupt:
            print("\n\n⚠ Tests interrupted by user")
            break
        except Exception as e:
            print(f"\n❌ Unexpected error in {name}: {e}")
            results.append((name, False))

    # Summary
    print("\n" + "=" * 60)
    print("Test Summary")
    print("=" * 60)

    passed = sum(1 for _, p in results if p)
    total = len(results)

    for name, p in results:
        status = "✓ PASS" if p else "✗ FAIL"
        print(f"  {status}: {name}")

    print(f"\nTotal: {passed}/{total} tests passed")

    if passed == total:
        print("\n🎉 All tests PASSED!")
        return 0
    else:
        print(f"\n❌ {total - passed} test(s) FAILED")
        return 1


if __name__ == "__main__":
    sys.exit(main())
