#!/usr/bin/env python3
"""Test new FlatBuffer features: multiple types and columns."""

import adbc_driver_cube as cube
import pyarrow as pa

# Connect
db = cube.connect(host="localhost", port=4445, connection_mode="native", token="test")
conn = cube.AdbcConnection(db)

print("Testing New FlatBuffer Features")
print("="*60)

# Test 1: DOUBLE
print("\n1. Testing DOUBLE type")
print("Query: SELECT 3.14159 as pi")
stmt = cube.AdbcStatement(conn)
stmt.set_sql_query("SELECT 3.14159 as pi")
stream, _ = stmt.execute_query()
reader = pa.RecordBatchReader._import_from_c(stream.address)
table = reader.read_all()
result = table.to_pydict()
print(f"   Result: {result}")
expected = 3.14159
actual = result['pi'][0]
if abs(actual - expected) < 0.00001:
    print(f"   ✅ PASS: Got {actual}")
else:
    print(f"   ❌ FAIL: Expected {expected}, got {actual}")
stmt.close()

# Test 2: BOOL
print("\n2. Testing BOOL type")
print("Query: SELECT true as flag")
stmt = cube.AdbcStatement(conn)
stmt.set_sql_query("SELECT true as flag")
stream, _ = stmt.execute_query()
reader = pa.RecordBatchReader._import_from_c(stream.address)
table = reader.read_all()
result = table.to_pydict()
print(f"   Result: {result}")
if result['flag'][0] == True:
    print(f"   ✅ PASS")
else:
    print(f"   ❌ FAIL: Expected True, got {result['flag'][0]}")
stmt.close()

# Test 3: STRING
print("\n3. Testing STRING type")
print("Query: SELECT 'hello' as greeting")
stmt = cube.AdbcStatement(conn)
stmt.set_sql_query("SELECT 'hello' as greeting")
stream, _ = stmt.execute_query()
reader = pa.RecordBatchReader._import_from_c(stream.address)
table = reader.read_all()
result = table.to_pydict()
print(f"   Result: {result}")
if result['greeting'][0] == 'hello':
    print(f"   ✅ PASS")
else:
    print(f"   ❌ FAIL: Expected 'hello', got {result['greeting'][0]}")
stmt.close()

# Test 4: Multiple Columns (INT64 + STRING)
print("\n4. Testing Multiple Columns (INT64 + STRING)")
print("Query: SELECT 1 as id, 'test' as name")
stmt = cube.AdbcStatement(conn)
stmt.set_sql_query("SELECT 1 as id, 'test' as name")
stream, _ = stmt.execute_query()
reader = pa.RecordBatchReader._import_from_c(stream.address)
table = reader.read_all()
result = table.to_pydict()
print(f"   Result: {result}")
if result['id'][0] == 1 and result['name'][0] == 'test':
    print(f"   ✅ PASS")
else:
    print(f"   ❌ FAIL: Expected {{id: [1], name: ['test']}}, got {result}")
stmt.close()

# Test 5: Multiple Columns (INT64 + DOUBLE + STRING)
print("\n5. Testing Multiple Columns (INT64 + DOUBLE + STRING)")
print("Query: SELECT 42 as num, 3.14 as pi, 'hello' as text")
stmt = cube.AdbcStatement(conn)
stmt.set_sql_query("SELECT 42 as num, 3.14 as pi, 'hello' as text")
stream, _ = stmt.execute_query()
reader = pa.RecordBatchReader._import_from_c(stream.address)
table = reader.read_all()
result = table.to_pydict()
print(f"   Result: {result}")
if result['num'][0] == 42 and abs(result['pi'][0] - 3.14) < 0.01 and result['text'][0] == 'hello':
    print(f"   ✅ PASS")
else:
    print(f"   ❌ FAIL")
stmt.close()

print("\n" + "="*60)
print("All new feature tests completed!")

conn.close()
db.close()
