#!/usr/bin/env python3
"""Quick test to check driver and connection"""

import sys
import os

print("Quick Connection Test")
print("=" * 60)

# Check library
print("\n1. Checking C driver library...")
lib_paths = [
    "/home/io/projects/learn_erl/adbc/priv/lib/libadbc_driver_cube.so"
]

lib_found = None
for path in lib_paths:
    if os.path.exists(path):
        lib_found = path
        print(f"   ✓ Found: {path}")
        break

if not lib_found:
    print("   ❌ Library not found!")
    sys.exit(1)

# Check port
print("\n2. Checking if port 4445 is listening...")
import subprocess
result = subprocess.run(
    ["lsof", "-i", ":4445"],
    capture_output=True,
    text=True
)
if result.returncode == 0:
    print("   ✓ Port 4445 is listening")
    print(f"   Process: {result.stdout.split()[10] if len(result.stdout.split()) > 10 else 'unknown'}")
else:
    print("   ❌ Port 4445 is NOT listening")
    print("   Start cubesqld with:")
    print("   cd /home/io/projects/learn_erl/cube/examples/recipes/arrow-ipc")
    print("   ./dev-start.sh")
    sys.exit(1)

# Try to import driver
print("\n3. Importing adbc_driver_cube...")
try:
    import adbc_driver_cube as cube
    print(f"   ✓ Imported successfully (v{cube.__version__})")
except ImportError as e:
    print(f"   ❌ Import failed: {e}")
    sys.exit(1)

# Try to connect
print("\n4. Attempting connection to localhost:4445...")
try:
    db = cube.connect(
        host="localhost",
        port=4445,
        connection_mode="native",
        token="test"
    )
    print("   ✓ Database object created")

    print("\n5. Creating connection...")
    conn = cube.AdbcConnection(db)
    print("   ✓ Connection created")

    print("\n6. Creating statement...")
    stmt = cube.AdbcStatement(conn)
    print("   ✓ Statement created")

    print("\n7. Setting SQL query...")
    stmt.set_sql_query("SELECT  orders.market_code, MEASURE(orders.count),  MEASURE(orders.discount_total_amount),  MEASURE(orders.tax_amount) FROM orders GROUP BY  1")
    print("   ✓ SQL query set")

    print("\n8. Executing query...")
    stream, _ = stmt.execute_query()
    print("   ✓ Query executed")

    print("\n9. Fetching results...")
    import pyarrow as pa
    # Convert ADBC stream handle to PyArrow table
    reader = pa.RecordBatchReader._import_from_c(stream.address)
    table = reader.read_all()
    print(f"   ✓ Got {len(table)} rows")
    print(f"   Data: {table.to_pydict()}")

    stmt.close()
    conn.close()
    db.close()

    print("\n✅ All checks PASSED!")
    print("\nReady to run full test suite:")
    print("  python test_driver.py")

except Exception as e:
    print(f"   ❌ Connection failed: {e}")
    import traceback
    traceback.print_exc()
    print("\n⚠ Make sure cubesqld is running with Arrow Native support")
    print("  cd /home/io/projects/learn_erl/cube/examples/recipes/arrow-ipc")
    print("  ./dev-start.sh")
    sys.exit(1)
