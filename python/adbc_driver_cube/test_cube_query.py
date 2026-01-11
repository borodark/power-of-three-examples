#!/usr/bin/env python3
"""Test real Cube query with dimensions and measures"""

import sys
sys.path.insert(0, "path/to/adbc/python/adbc_driver_cube")

import adbc_driver_cube as cube

print("Testing Cube query with dimensions and measures")
print("=" * 60)

try:
    db = cube.connect(
        host="localhost",
        port=4445,
        connection_mode="native",
        token="test"
    )
    print("✓ Connected to Cube server")

    conn = cube.AdbcConnection(db)
    stmt = cube.AdbcStatement(conn)

    # Real Cube query with dimension and measure
    sql = """
    SELECT
  orders.brand,
  MEASURE(orders.count),
  MEASURE(orders.subtotal_amount),
  MEASURE(orders.tax_amount),
  MEASURE(orders.total_amount)
FROM
  orders
GROUP BY 1"""
    print(f"\nQuery: {sql}")

    stmt.set_sql_query(sql)
    stream, _ = stmt.execute_query()

    import pyarrow as pa
    reader = pa.RecordBatchReader._import_from_c(stream.address)
    table = reader.read_all()

    print(f"\n✓ Got {len(table)} rows")
    print(f"\nSchema:")
    print(table.schema)
    print(f"\nData:")
    import pandas as pd
    df_arrow = table.to_pandas()
    print(df_arrow)

    stmt.close()
    conn.close()
    db.close()

    print("\n✅ Test completed successfully!")

except Exception as e:
    print(f"\n✗ Test failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)
