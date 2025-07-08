#!/usr/bin/env bats

load ../test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

@test "github hook exists and is executable" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/ci/github.sh" ]]; then
    skip "Hook file not found - hooks may not be committed yet"
  fi

  run test -x "$ORIGINAL_DIR/hooks/ci/github.sh"
  [ "$status" -eq 0 ]
}

@test "github hook installs actionlint if needed" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/ci/github.sh" ]]; then
    skip "Hook file not found"
  fi

  # Mock go install
  mock_command "go" "echo 'Installing actionlint'; exit 0"
  mock_command "actionlint" "echo 'Actionlint run'; exit 0"

  # No package.json means it should install
  run "$ORIGINAL_DIR/hooks/ci/github.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Installing actionlint" ]]
  [[ "$output" =~ "Actionlint run" ]]
}

@test "github hook skips install with package.json" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/ci/github.sh" ]]; then
    skip "Hook file not found"
  fi

  # Create package.json
  echo '{}' > package.json

  mock_command "actionlint" "echo 'Actionlint run'; exit 0"

  run "$ORIGINAL_DIR/hooks/ci/github.sh"
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Actionlint run" ]]
  [[ ! "$output" =~ "Installing" ]]
}

@test "github hook reports actionlint errors" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/ci/github.sh" ]]; then
    skip "Hook file not found"
  fi

  echo '{}' > package.json
  mock_command "actionlint" "echo 'Error in workflow'; exit 1"

  run "$ORIGINAL_DIR/hooks/ci/github.sh"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "Error in workflow" ]]
}
