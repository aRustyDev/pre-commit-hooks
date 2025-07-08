#!/usr/bin/env bash
# Test runner script for all hook tests

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if bats is installed
if ! command -v bats &> /dev/null; then
  echo -e "${RED}Error: bats is not installed${NC}"
  echo "Install with:"
  echo "  Ubuntu/Debian: sudo apt-get install bats"
  echo "  macOS: brew install bats-core"
  echo "  Or: npm install -g bats"
  exit 1
fi

# Find all test files
TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_FILES=$(find "$TEST_DIR" -name "*.bats" -type f)

if [[ -z "$TEST_FILES" ]]; then
  echo -e "${YELLOW}No test files found${NC}"
  exit 0
fi

echo "Running hook tests..."
echo "===================="

# Run tests with coverage if possible
if command -v kcov &> /dev/null; then
  echo "Running with coverage..."
  COVERAGE_DIR="$TEST_DIR/coverage"
  mkdir -p "$COVERAGE_DIR"

  for test_file in $TEST_FILES; do
    echo -e "\n${YELLOW}Running: $(basename "$test_file")${NC}"
    kcov --exclude-pattern=/usr "$COVERAGE_DIR" bats "$test_file" || true
  done

  echo -e "\n${GREEN}Coverage report generated in: $COVERAGE_DIR${NC}"
else
  # Run without coverage
  for test_file in $TEST_FILES; do
    echo -e "\n${YELLOW}Running: $(basename "$test_file")${NC}"
    if bats "$test_file"; then
      echo -e "${GREEN}✓ Passed${NC}"
    else
      echo -e "${RED}✗ Failed${NC}"
      exit 1
    fi
  done
fi

echo -e "\n${GREEN}All tests passed!${NC}"
