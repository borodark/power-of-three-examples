#!/usr/bin/env python3
"""Test extraction of different INT64 values from Cube."""

import adbc_driver_cube as cube
import pyarrow as pa

# Connect
db = cube.connect(host="localhost", port=4445, connection_mode="native", token="test")
conn = cube.AdbcConnection(db)

# Test queries with different values
test_queries = [
    "SELECT 1 as test",
    "SELECT 42 as test",
    "SELECT 12345 as test",
    "SELECT -99 as test",
]

for query in test_queries:
    print(f"\nQuery: {query}")
    stmt = cube.AdbcStatement(conn)
    stmt.set_sql_query(query)
    stream, _ = stmt.execute_query()

    reader = pa.RecordBatchReader._import_from_c(stream.address)
    table = reader.read_all()
    result = table.to_pydict()
    print(f"  Result: {result}")
    stmt.close()

conn.close()
db.close()
