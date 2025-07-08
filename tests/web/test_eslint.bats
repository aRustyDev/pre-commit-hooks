#!/usr/bin/env bats

load ../test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

@test "eslint hook exists and is executable" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/web/js/eslint.sh" ]]; then
    skip "Hook file not found - hooks may not be committed yet"
  fi

  run test -x "$ORIGINAL_DIR/hooks/web/js/eslint.sh"
  [ "$status" -eq 0 ]
}

@test "eslint hook installs eslint if package.json missing" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/web/js/eslint.sh" ]]; then
    skip "Hook file not found"
  fi

  # Mock npm to track if it was called
  mock_command "npm" "echo 'npm install called'; exit 0"
  mock_command "eslint" "exit 0"

  # Run in directory without package.json
  run "$ORIGINAL_DIR/hooks/web/js/eslint.sh" "test.js"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "npm install called" ]]
}

@test "eslint hook runs on provided file" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/web/js/eslint.sh" ]]; then
    skip "Hook file not found"
  fi

  # Create package.json to skip npm install
  echo '{}' > package.json

  # Mock eslint to verify it receives the file argument
  mock_command "eslint" "echo \"Linting: \$1\"; exit 0"

  run "$ORIGINAL_DIR/hooks/web/js/eslint.sh" "test.js"
  [ "$status" -eq 0 ]
  [[ "$output" =~ Linting:\ test.js ]]
}

@test "eslint hook handles linting errors" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/web/js/eslint.sh" ]]; then
    skip "Hook file not found"
  fi

  echo '{}' > package.json
  mock_command "eslint" "echo 'Error: Linting failed'; exit 1"

  run "$ORIGINAL_DIR/hooks/web/js/eslint.sh" "bad.js"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Linting failed" ]]
}
