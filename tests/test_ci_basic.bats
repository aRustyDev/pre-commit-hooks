#!/usr/bin/env bats

load test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

@test "test helper functions work" {
  # Basic test to ensure test infrastructure works
  create_test_file "test.txt" "hello world"
  assert_file_exists "test.txt"
  assert_file_contains "test.txt" "hello"
}

@test "git initialization works in test environment" {
  # Verify git is initialized in test env
  run git status
  [ "$status" -eq 0 ]
}

@test "mock command functionality" {
  # Test that mocking works
  mock_command "fake-command" "echo 'mocked output'; exit 42"

  run fake-command
  [ "$status" -eq 42 ]
  [[ "$output" == "mocked output" ]]
}

@test "CI environment detection" {
  # This should pass in CI
  if [[ -n "$CI" ]]; then
    echo "Running in CI environment"
  else
    skip "Not running in CI"
  fi
}
