#!/usr/bin/env python3
"""
Setup script for adbc_driver_cube
"""

from setuptools import setup, find_packages
import os

# Read version from __init__.py
here = os.path.abspath(os.path.dirname(__file__))
about = {}
with open(os.path.join(here, "adbc_driver_cube", "__init__.py"), "r") as f:
    for line in f:
        if line.startswith("__version__"):
            exec(line, about)
            break

# Read README if it exists
readme = ""
readme_path = os.path.join(here, "README.md")
if os.path.exists(readme_path):
    with open(readme_path, "r", encoding="utf-8") as f:
        readme = f.read()

setup(
    name="adbc_driver_cube",
    version=about.get("__version__", "0.1.0"),
    description="ADBC Driver for Cube with Arrow Native Protocol Support",
    long_description=readme,
    long_description_content_type="text/markdown",
    author="Cube ADBC Contributors",
    author_email="",
    url="https://github.com/cube-js/cube",
    packages=find_packages(),
    install_requires=[
        "adbc-driver-manager>=0.8.0",
        "pyarrow>=12.0.0",
    ],
    extras_require={
        "dev": [
            "pytest>=7.0.0",
            "pytest-asyncio>=0.20.0",
            "black>=22.0.0",
            "mypy>=0.990",
        ],
    },
    python_requires=">=3.8",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: Apache Software License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Topic :: Database",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
    keywords="adbc arrow database cube analytics",
)
