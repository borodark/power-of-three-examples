"""
ADBC Driver for Cube with Arrow Native Protocol Support

This driver provides connectivity to Cube.js via two protocols:
- PostgreSQL wire protocol (default, backward compatible)
- Arrow Native protocol (high-performance Arrow IPC streaming)
"""

import os
import sys
from typing import Optional, Dict, Any

try:
    import adbc_driver_manager
    from adbc_driver_manager import (
        DatabaseOptions,
        ConnectionOptions,
        StatementOptions,
    )
except ImportError:
    raise ImportError(
        "adbc_driver_manager is required. Install it with: pip install adbc-driver-manager"
    )

__version__ = "0.1.0"

# Default library paths to search
_DEFAULT_LIBRARY_PATHS = [
    # Installed location (priv directory)
    "/home/io/projects/learn_erl/adbc/priv/lib/libadbc_driver_cube.so",
    # Build output (_build directory)
    "/home/io/projects/learn_erl/adbc/_build/cmake/adbc/driver/cube/libadbc_driver_cube.so",
    # System installed locations
    "/usr/local/lib/libadbc_driver_cube.so",
    "/usr/lib/libadbc_driver_cube.so",
    # Relative to package
    os.path.join(os.path.dirname(__file__), "libadbc_driver_cube.so"),
]


def _find_driver_library() -> str:
    """Find the Cube ADBC driver library."""
    # Check environment variable first
    env_path = os.environ.get("ADBC_CUBE_LIBRARY")
    if env_path and os.path.exists(env_path):
        return env_path

    # Search default paths
    for path in _DEFAULT_LIBRARY_PATHS:
        if os.path.exists(path):
            return path

    raise FileNotFoundError(
        f"Could not find libadbc_driver_cube.so. Searched paths:\n"
        + "\n".join(f"  - {p}" for p in _DEFAULT_LIBRARY_PATHS)
        + "\n\nSet ADBC_CUBE_LIBRARY environment variable to specify the path."
    )


def connect(
    uri: Optional[str] = None,
    *,
    host: Optional[str] = None,
    port: Optional[int] = None,
    database: Optional[str] = None,
    token: Optional[str] = None,
    user: Optional[str] = None,
    password: Optional[str] = None,
    connection_mode: str = "postgresql",
    db_kwargs: Optional[Dict[str, Any]] = None,
    **kwargs,
) -> adbc_driver_manager.AdbcDatabase:
    """
    Connect to Cube using ADBC.

    Parameters
    ----------
    uri : str, optional
        Connection URI in format "host:port"
    host : str, optional
        Cube server hostname (default: "localhost")
    port : int, optional
        Cube server port (default: 4444 for PostgreSQL, 4445 for native)
    database : str, optional
        Database name
    token : str, optional
        Authentication token (required for native mode)
    user : str, optional
        Username (for PostgreSQL mode)
    password : str, optional
        Password (for PostgreSQL mode)
    connection_mode : str, optional
        Connection mode: "postgresql" (default) or "native"/"arrow_native"
        - "postgresql": Use PostgreSQL wire protocol (backward compatible)
        - "native" or "arrow_native": Use Arrow Native protocol (high performance)
    db_kwargs : dict, optional
        Additional database options
    **kwargs : dict
        Additional connection options

    Returns
    -------
    AdbcDatabase
        Connected database instance

    Examples
    --------
    PostgreSQL mode (default):
    >>> db = connect(host="localhost", port=4444, user="root", password="")

    Arrow Native mode (high performance):
    >>> db = connect(
    ...     host="localhost",
    ...     port=4445,
    ...     connection_mode="native",
    ...     token="your-cube-token"
    ... )

    Using URI:
    >>> db = connect(uri="localhost:4445", db_kwargs={"connection_mode": "native"})
    """
    # Find the driver library
    driver_path = _find_driver_library()

    # Parse URI if provided
    if uri:
        if ":" in uri:
            host, port_str = uri.rsplit(":", 1)
            port = int(port_str)
        else:
            host = uri

    # Set defaults
    if host is None:
        host = "localhost"
    if port is None:
        # Default port based on connection mode
        mode = (db_kwargs or {}).get("connection_mode", connection_mode).lower()
        port = 4445 if mode in ("native", "arrow_native") else 4444

    # Merge db_kwargs
    if db_kwargs:
        connection_mode = db_kwargs.pop("connection_mode", connection_mode)
        token = db_kwargs.pop("token", token)
        database = db_kwargs.pop("database", database)
        user = db_kwargs.pop("user", user)
        password = db_kwargs.pop("password", password)

    # Build options dictionary
    options = {
        "driver": driver_path,
        "adbc.cube.host": host,
        "adbc.cube.port": str(port),
        "adbc.cube.connection_mode": connection_mode.lower(),
    }

    if database:
        options["adbc.cube.database"] = database
    if token:
        options["adbc.cube.token"] = token
    if user:
        options["adbc.cube.user"] = user
    if password:
        options["adbc.cube.password"] = password

    # Add any additional options
    if db_kwargs:
        for key, value in db_kwargs.items():
            options[f"adbc.cube.{key}"] = str(value)
    if kwargs:
        for key, value in kwargs.items():
            options[f"adbc.cube.{key}"] = str(value)

    # Create database connection
    db = adbc_driver_manager.AdbcDatabase(**options)
    return db


# Convenience aliases
AdbcConnection = adbc_driver_manager.AdbcConnection
AdbcDatabase = adbc_driver_manager.AdbcDatabase
AdbcStatement = adbc_driver_manager.AdbcStatement


__all__ = [
    "connect",
    "AdbcConnection",
    "AdbcDatabase",
    "AdbcStatement",
    "DatabaseOptions",
    "ConnectionOptions",
    "StatementOptions",
    "__version__",
]
