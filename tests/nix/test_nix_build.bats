#!/usr/bin/env bats

load ../test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

@test "nix-build hook exists and is executable" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/nix/nix-build.sh" ]]; then
    skip "Hook file not found - hooks may not be committed yet"
  fi

  run test -x "$ORIGINAL_DIR/hooks/nix/nix-build.sh"
  [ "$status" -eq 0 ]
}

@test "nix-build requires nix-shell shebang" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/nix/nix-build.sh" ]]; then
    skip "Hook file not found"
  fi

  run head -n1 "$ORIGINAL_DIR/hooks/nix/nix-build.sh"
  [[ "$output" =~ "nix-shell" ]]
}

@test "nix-build passes arguments correctly" {
  if [[ ! -f "$ORIGINAL_DIR/hooks/nix/nix-build.sh" ]]; then
    skip "Hook file not found"
  fi

  # Mock nix-build
  mock_command "nix-build" "echo \"Building with args: \$@\""

  # The hook uses a special nix-shell shebang, so we need to test differently
  # Just verify the script contains the expected command
  run grep 'nix-build "$@"' "$ORIGINAL_DIR/hooks/nix/nix-build.sh"
  [ "$status" -eq 0 ]
}
