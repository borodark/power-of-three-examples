#!/bin/bash
# Run basic Cube ADBC driver tests (stable subset)
# Requires cubesqld to be running with Arrow Native protocol

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Cube ADBC Driver - Basic Tests${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""

# Check if driver library exists
DRIVER_PATH="$PROJECT_DIR/priv/lib/libadbc_driver_cube.so"
if [ ! -f "$DRIVER_PATH" ]; then
    echo -e "${RED}Error: Cube driver not found at $DRIVER_PATH${NC}"
    echo ""
    echo "Build it with:"
    echo "  cd $PROJECT_DIR"
    echo "  make"
    exit 1
fi
echo -e "${GREEN}✓ Cube driver found${NC}"

# Check if cubesqld is running
if ! lsof -Pi :4445 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${RED}Error: cubesqld is not running on port 4445${NC}"
    echo ""
    echo "Start it with:"
    echo "  cd ~/projects/learn_erl/cube/examples/recipes/arrow-ipc"
    echo "  ./start-cube-api.sh    # Terminal 1"
    echo "  ./start-cubesqld.sh    # Terminal 2"
    exit 1
fi
echo -e "${GREEN}✓ cubesqld is running on port 4445${NC}"

# Check if Cube API is running
if ! lsof -Pi :4008 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}Warning: Cube API may not be running on port 4008${NC}"
fi

echo ""
echo -e "${GREEN}Running basic Cube ADBC tests (6 tests)...${NC}"
echo ""

cd "$PROJECT_DIR"

# Run only basic Cube tests
if [ "$1" == "--verbose" ] || [ "$1" == "-v" ]; then
    mix test test/adbc_cube_basic_test.exs --trace --include cube
else
    mix test test/adbc_cube_basic_test.exs --include cube
fi

EXIT_CODE=$?

echo ""
if [ $EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✅ All basic Cube tests passed!${NC}"
    echo ""
    echo "These tests verify:"
    echo "  - Connection to cubesqld"
    echo "  - Basic SELECT queries (integers)"
    echo "  - Data types: STRING, DOUBLE, BOOLEAN"
    echo "  - Cube dimension queries"
else
    echo -e "${RED}❌ Some tests failed${NC}"
fi

exit $EXIT_CODE
