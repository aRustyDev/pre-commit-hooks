#!/usr/bin/env bash

# Check for required commands
for cmd in nix nix-build; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$cmd is not installed"
    exit 1
  fi
done

PASS=true
DRY_RUN="${NIX_BUILD_DRY_RUN:-false}"
BUILD_ARGS="${NIX_BUILD_ARGS:-}"

# Process each file
for file in "$@"; do
  # Skip non-nix files
  if [[ ! "$file" =~ \.nix$ ]]; then
    continue
  fi

  echo "Checking build for $file..."

  # Determine if this is a flake or legacy nix file
  if [[ "$(basename "$file")" == "flake.nix" ]]; then
    # For flakes, build from the directory
    flake_dir="$(dirname "$file")"

    if [[ "$DRY_RUN" == "true" ]]; then
      echo "Running dry build for flake in $flake_dir..."
      # shellcheck disable=SC2086
      if ! nix build "$flake_dir" --dry-run $BUILD_ARGS 2>&1; then
        echo "ERROR: Flake build check failed for $file"
        PASS=false
      else
        echo "✓ Flake build check passed for $file"
      fi
    else
      echo "Running build for flake in $flake_dir..."
      # shellcheck disable=SC2086
      if ! nix build "$flake_dir" --no-link $BUILD_ARGS 2>&1; then
        echo "ERROR: Flake build failed for $file"
        PASS=false
      else
        echo "✓ Flake build passed for $file"
      fi
    fi
  else
    # For legacy nix files
    if [[ "$DRY_RUN" == "true" ]]; then
      echo "Running dry build for $file..."
      # shellcheck disable=SC2086
      if ! nix-build "$file" --dry-run --no-out-link $BUILD_ARGS 2>&1; then
        echo "ERROR: Build check failed for $file"
        PASS=false
      else
        echo "✓ Build check passed for $file"
      fi
    else
      echo "Running build for $file..."
      # shellcheck disable=SC2086
      if ! nix-build "$file" --no-out-link $BUILD_ARGS 2>&1; then
        echo "ERROR: Build failed for $file"
        PASS=false
      else
        echo "✓ Build passed for $file"
      fi
    fi
  fi
done

if ! $PASS; then
  exit 1
fi
