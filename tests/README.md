# Pre-commit Hooks Test Suite

This directory contains automated tests for all pre-commit hooks using the [bats](https://github.com/bats-core/bats-core) testing framework.

## Structure

```
tests/
├── test_helper.bash    # Common test utilities
├── run_tests.sh       # Test runner script
├── commits/           # Tests for commit hooks
├── nix/              # Tests for Nix hooks
├── terraform/        # Tests for Terraform hooks
├── web/              # Tests for web-related hooks
└── configs/          # Tests for config hooks
```

## Running Tests

### Prerequisites

Install bats:
```bash
# Ubuntu/Debian
sudo apt-get install bats

# macOS
brew install bats-core

# Via npm
npm install -g bats
```

### Run All Tests
```bash
./tests/run_tests.sh
```

### Run Specific Test File
```bash
bats tests/commits/test_gitlint.bats
```

### Run with Coverage
```bash
# Install kcov first
./tests/run_tests.sh  # Will automatically use kcov if available
```

## Writing Tests

Each hook should have a corresponding test file following the pattern:
`tests/<category>/test_<hook-name>.bats`

Example test structure:
```bash
#!/usr/bin/env bats

load ../test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

@test "hook exists and is executable" {
  run test -x "$ORIGINAL_DIR/hooks/category/hook.sh"
  [ "$status" -eq 0 ]
}

@test "hook validates input correctly" {
  # Test implementation
}
```

## Test Guidelines

1. **Coverage**: Every hook must have at least basic tests
2. **Edge Cases**: Test error conditions and edge cases
3. **Mocking**: Use `mock_command` for external dependencies
4. **Isolation**: Each test should be independent
5. **Performance**: Keep tests fast (<1s per test)

## CI Integration

Tests run automatically on:
- Every push to main branch
- Every pull request
- Multiple OS environments (Ubuntu, macOS)

See `.github/workflows/ci.yml` for CI configuration.
