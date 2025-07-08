#!/usr/bin/env bats

load ../test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

@test "gitlint hook exists and is executable" {
  # Check if the hook file exists first
  if [[ ! -f "$ORIGINAL_DIR/hooks/commits/gitlint.sh" ]]; then
    skip "Hook file not found - hooks may not be committed yet"
  fi

  run test -x "$ORIGINAL_DIR/hooks/commits/gitlint.sh"
  [ "$status" -eq 0 ]
}

@test "gitlint hook fails without gitlint installed" {
  # Mock gitlint as not installed
  mock_command "gitlint" "exit 127"

  run "$ORIGINAL_DIR/hooks/commits/gitlint.sh"
  [ "$status" -ne 0 ]
}

@test "gitlint hook validates commit message" {
  # Mock gitlint to succeed
  mock_command "gitlint" "exit 0"

  create_test_file
  create_commit "feat: valid commit message"

  run "$ORIGINAL_DIR/hooks/commits/gitlint.sh"
  [ "$status" -eq 0 ]
}

@test "gitlint hook fails on invalid commit message" {
  # Mock gitlint to fail
  mock_command "gitlint" "echo 'Invalid commit message format' >&2; exit 1"

  create_test_file
  create_commit "bad commit"

  run "$ORIGINAL_DIR/hooks/commits/gitlint.sh"
  [ "$status" -eq 1 ]
}

@test "gitlint hook handles empty repository" {
  # Don't create any commits
  mock_command "gitlint" "exit 0"

  run "$ORIGINAL_DIR/hooks/commits/gitlint.sh"
  # Should handle gracefully
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}
