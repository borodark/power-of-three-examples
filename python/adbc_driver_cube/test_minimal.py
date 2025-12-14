#!/usr/bin/env python3
"""Minimal test to debug connection"""

import sys
sys.path.insert(0, "/home/io/projects/learn_erl/adbc/python/adbc_driver_cube")

print("1. Importing module...")
try:
    import adbc_driver_cube as cube
    print(f"   ✓ Imported (v{cube.__version__})")
except Exception as e:
    print(f"   ✗ Import failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n2. Creating database connection...")
try:
    db = cube.connect(
        host="localhost",
        port=4445,
        connection_mode="native",
        token="test"
    )
    print("   ✓ Database object created")
except Exception as e:
    print(f"   ✗ Failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n3. Creating ADBC connection...")
try:
    conn = cube.AdbcConnection(db)
    print("   ✓ Connection created")
except Exception as e:
    print(f"   ✗ Failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n4. Creating statement...")
try:
    stmt = cube.AdbcStatement(conn)
    print("   ✓ Statement created")
except Exception as e:
    print(f"   ✗ Failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n5. Setting simple query...")
try:
    stmt.set_sql_query("SELECT 1 as test")
    print("   ✓ SQL query set")
except Exception as e:
    print(f"   ✗ Failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n6. Executing query...")
try:
    stream, _ = stmt.execute_query()
    print("   ✓ Query executed, got stream")
    print(f"   Stream address: {stream.address}")
except Exception as e:
    print(f"   ✗ Failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n7. Reading results...")
try:
    import pyarrow as pa
    reader = pa.RecordBatchReader._import_from_c(stream.address)
    print("   ✓ Created PyArrow reader")

    table = reader.read_all()
    print(f"   ✓ Read {len(table)} rows")
    print(f"   Data: {table.to_pydict()}")
except Exception as e:
    print(f"   ✗ Failed: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n✅ All steps completed!")
stmt.close()
conn.close()
db.close()
