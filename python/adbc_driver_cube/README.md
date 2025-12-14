# ADBC Driver for Cube

Python ADBC driver for Cube.js with Arrow Native Protocol support.

## Features

- **Dual Protocol Support**:
  - PostgreSQL wire protocol (default, backward compatible)
  - Arrow Native protocol (high-performance Arrow IPC streaming)
- **Zero-copy data transfer** with Arrow Native protocol
- **Standard ADBC interface** compatible with all ADBC tools
- **PyArrow integration** for native Arrow tables

## Installation

```bash
# Install from local directory
pip install -e .

# Or with dependencies
pip install adbc-driver-manager pyarrow
```

## Usage

### Arrow Native Protocol (Recommended)

```python
import adbc_driver_cube as cube
import pyarrow as pa

# Connect using Arrow Native protocol
db = cube.connect(
    host="localhost",
    port=4445,
    connection_mode="native",
    token="your-cube-token"
)

# Execute query
with db.cursor() as cur:
    cur.execute("SELECT * FROM orders WHERE amount > 100 LIMIT 1000")

    # Get results as Arrow table (zero-copy)
    table = cur.fetch_arrow_table()
    print(f"Rows: {len(table)}")
    print(table.schema)

    # Or as pandas DataFrame
    df = table.to_pandas()
    print(df.head())
```

### PostgreSQL Protocol (Default)

```python
import adbc_driver_cube as cube

# Connect using PostgreSQL protocol
db = cube.connect(
    host="localhost",
    port=4444,
    user="root",
    password=""
)

with db.cursor() as cur:
    cur.execute("SELECT * FROM orders LIMIT 10")
    table = cur.fetch_arrow_table()
    print(table)
```

### Using Connection URI

```python
# Arrow Native
db = cube.connect(
    uri="localhost:4445",
    db_kwargs={
        "connection_mode": "native",
        "token": "your-token"
    }
)

# PostgreSQL
db = cube.connect(
    uri="localhost:4444",
    db_kwargs={
        "user": "root",
        "password": ""
    }
)
```

## Connection Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `uri` | str | None | Connection URI (host:port) |
| `host` | str | "localhost" | Cube server hostname |
| `port` | int | 4444/4445* | Server port |
| `connection_mode` | str | "postgresql" | "postgresql" or "native" |
| `token` | str | None | Auth token (required for native) |
| `user` | str | None | Username (for PostgreSQL) |
| `password` | str | None | Password (for PostgreSQL) |
| `database` | str | None | Database name |

*Default port: 4444 for PostgreSQL mode, 4445 for native mode

## Performance Comparison

```python
import time

def benchmark_protocol(mode, port):
    db = cube.connect(
        host="localhost",
        port=port,
        connection_mode=mode,
        token="test" if mode == "native" else None,
        user="root" if mode == "postgresql" else None
    )

    start = time.time()
    with db.cursor() as cur:
        cur.execute("SELECT * FROM large_table LIMIT 100000")
        table = cur.fetch_arrow_table()
    elapsed = time.time() - start

    return elapsed, len(table)

# Compare protocols
pg_time, pg_rows = benchmark_protocol("postgresql", 4444)
native_time, native_rows = benchmark_protocol("native", 4445)

print(f"PostgreSQL: {pg_time:.2f}s for {pg_rows:,} rows")
print(f"Arrow Native: {native_time:.2f}s for {native_rows:,} rows")
print(f"Speedup: {pg_time/native_time:.2f}x")
```

## Advanced Usage

### Batch Processing

```python
db = cube.connect(uri="localhost:4445", db_kwargs={"connection_mode": "native"})

with db.cursor() as cur:
    cur.execute("SELECT * FROM orders")

    # Process in batches
    while True:
        batch = cur.fetch_record_batch()
        if batch is None:
            break

        print(f"Processing batch: {len(batch)} rows")
        # Process batch...
```

### Parameterized Queries

```python
with db.cursor() as cur:
    # Safe parameter binding
    cur.execute(
        "SELECT * FROM orders WHERE amount > ? AND status = ?",
        parameters=[100, "completed"]
    )
    table = cur.fetch_arrow_table()
```

### Metadata Queries

```python
with db.cursor() as cur:
    # List tables
    cur.execute("SHOW TABLES")
    tables = cur.fetchall()

    # Describe table
    cur.execute("DESCRIBE orders")
    schema = cur.fetchall()
```

## Requirements

- Python >= 3.8
- adbc-driver-manager >= 0.8.0
- pyarrow >= 12.0.0
- libadbc_driver_cube.so (C driver library)

## Building the C Driver

The Python package requires the C driver library. Build it with:

```bash
cd /home/io/projects/learn_erl/adbc
mkdir -p cmake_adbc && cd cmake_adbc
cmake ../3rd_party/apache-arrow-adbc/c -DADBC_DRIVER_CUBE=ON
make adbc_driver_cube_shared
sudo make install
```

## Environment Variables

- `ADBC_CUBE_LIBRARY`: Path to libadbc_driver_cube.so

## Troubleshooting

### Driver Library Not Found

```python
# Set library path explicitly
import os
os.environ["ADBC_CUBE_LIBRARY"] = "/path/to/libadbc_driver_cube.so"
import adbc_driver_cube as cube
```

### Connection Refused

Ensure Cube server is running:
```bash
# Check if server is listening
lsof -i :4445  # For native protocol
lsof -i :4444  # For PostgreSQL protocol
```

## License

Apache License 2.0
