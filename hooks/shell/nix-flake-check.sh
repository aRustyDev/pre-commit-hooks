#!/usr/bin/env bash

# Check for required commands
if ! command -v nix &> /dev/null; then
  echo "nix is not installed"
  exit 1
fi

# Check if experimental features are enabled
if ! nix --version &> /dev/null || ! nix flake --help &> /dev/null 2>&1; then
  echo "Nix flakes experimental feature is not enabled"
  echo "Add 'experimental-features = nix-command flakes' to your nix.conf"
  exit 1
fi

PASS=true

# Process each file
for file in "$@"; do
  # Skip if not a flake.nix file
  if [[ "$(basename "$file")" != "flake.nix" ]]; then
    continue
  fi

  # Get the directory containing the flake
  flake_dir="$(dirname "$file")"

  echo "Checking flake in $flake_dir..."

  # Run flake check
  if ! nix flake check "$flake_dir" 2>&1; then
    echo "ERROR: Flake check failed for $file"
    PASS=false
  else
    echo "✓ Flake check passed for $file"
  fi

  # Optionally show flake structure (useful for debugging)
  if [[ "${NIX_FLAKE_SHOW:-false}" == "true" ]]; then
    echo "Flake structure:"
    nix flake show "$flake_dir" 2>&1 || true
  fi
done

if ! $PASS; then
  exit 1
fi
