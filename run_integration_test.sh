#!/bin/bash
# Script to compile and run integration_test_final.cpp

set -e  # Exit on error

echo "================================================"
echo "Cube SQL ADBC Driver - Integration Test Runner"
echo "================================================"
echo ""

# Compile the integration test
echo "Compiling integration_test_final.cpp..."
g++ -std=c++17 \
    -o /tmp/integration_test_final \
    integration_test_final.cpp \
    -I/usr/include/postgresql \
    -lpq \
    -Wall

if [ $? -eq 0 ]; then
    echo "✓ Compilation successful"
    echo ""
else
    echo "✗ Compilation failed"
    exit 1
fi

# Run the integration test
echo "Running integration tests against Cube SQL (localhost:4444)..."
echo "================================================"
echo ""

/tmp/integration_test_final

# Capture exit code
TEST_EXIT_CODE=$?

echo ""
echo "================================================"
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo "✓ All tests completed"
else
    echo "✗ Tests failed with exit code: $TEST_EXIT_CODE"
fi
echo "================================================"

exit $TEST_EXIT_CODE
