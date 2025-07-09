#!/usr/bin/env bats

load ../test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

@test "nix-fmt hook exists and is executable" {
  run test -x "$ORIGINAL_DIR/hooks/nix/nix-fmt.sh"
  [ "$status" -eq 0 ]
}

@test "nix-fmt formats nix files" {
  # Create unformatted nix file
  cat > default.nix << 'EOF'
{pkgs}:
pkgs.mkShell{
buildInputs=[pkgs.hello];
}
EOF

  # Mock nixpkgs-fmt
  mock_command "nixpkgs-fmt" "echo '{ pkgs }:
pkgs.mkShell {
  buildInputs = [ pkgs.hello ];
}' > \"\$1\""

  run "$ORIGINAL_DIR/hooks/nix/nix-fmt.sh"
  [ "$status" -eq 0 ]

  # Check file was formatted
  assert_file_contains "default.nix" "buildInputs ="
}

@test "nix-fmt handles missing nix files gracefully" {
  # No nix files in directory
  mock_command "nixpkgs-fmt" "exit 0"

  run "$ORIGINAL_DIR/hooks/nix/nix-fmt.sh"
  [ "$status" -eq 0 ]
}

@test "nix-fmt reports formatting errors" {
  create_test_file "invalid.nix" "{ this is not valid nix"

  mock_command "nixpkgs-fmt" "echo 'Error: Invalid syntax' >&2; exit 1"

  run "$ORIGINAL_DIR/hooks/nix/nix-fmt.sh"
  [ "$status" -eq 1 ]
}
