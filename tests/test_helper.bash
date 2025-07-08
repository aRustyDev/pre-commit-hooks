#!/usr/bin/env bash
# Test helper functions for bats tests

# Setup function to create temporary test environment
setup_test_env() {
  TEST_DIR="$(mktemp -d)"
  export TEST_DIR
  ORIGINAL_DIR="$(pwd)"
  export ORIGINAL_DIR
  cd "$TEST_DIR" || exit 1

  # Initialize git repo for tests that need it
  git init --quiet
  git config user.email "test@example.com"
  git config user.name "Test User"
}

# Teardown function to clean up
teardown_test_env() {
  cd "$ORIGINAL_DIR" || exit 1
  rm -rf "$TEST_DIR"
}

# Helper to create a test file
create_test_file() {
  local filename="${1:-test.txt}"
  local content="${2:-test content}"
  echo "$content" > "$filename"
}

# Helper to create a git commit
create_commit() {
  local message="${1:-test commit}"
  git add -A
  git commit -m "$message" --quiet
}

# Assert file exists
assert_file_exists() {
  local file="$1"
  [[ -f "$file" ]] || {
    echo "File not found: $file"
    return 1
  }
}

# Assert file contains text
assert_file_contains() {
  local file="$1"
  local text="$2"
  grep -q "$text" "$file" || {
    echo "File $file does not contain: $text"
    return 1
  }
}

# Assert command succeeds
assert_success() {
  local cmd="$1"
  $cmd || {
    echo "Command failed: $cmd"
    return 1
  }
}

# Assert command fails
assert_failure() {
  local cmd="$1"
  ! $cmd || {
    echo "Command should have failed: $cmd"
    return 1
  }
}

# Mock command for testing
mock_command() {
  local cmd_name="$1"
  local mock_behavior="$2"

  # Create a mock script
  cat > "$TEST_DIR/$cmd_name" << EOF
#!/usr/bin/env bash
$mock_behavior
EOF

  chmod +x "$TEST_DIR/$cmd_name"
  export PATH="$TEST_DIR:$PATH"
}
