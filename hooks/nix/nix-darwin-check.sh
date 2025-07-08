#!/usr/bin/env bash

# Check if we're on Darwin
if [[ "$(uname)" != "Darwin" ]]; then
  echo "Skipping nix-darwin check on non-Darwin platform"
  exit 0
fi

# Check for required commands
for cmd in nix darwin-rebuild; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$cmd is not installed"
    echo "Please install nix-darwin: https://github.com/LnL7/nix-darwin"
    exit 1
  fi
done

PASS=true
CHECK_MODE="${DARWIN_CHECK_MODE:-check}" # Options: check, dry-build

# Process each file
for file in "$@"; do
  # Skip non-nix files
  if [[ ! "$file" =~ \.nix$ ]]; then
    continue
  fi

  # Skip files that don't look like darwin configurations
  if ! grep -q "darwin\|nix-darwin" "$file" 2> /dev/null; then
    continue
  fi

  echo "Checking darwin configuration: $file..."

  # Determine if this is a flake-based darwin config
  flake_dir="$(dirname "$file")"
  if [[ -f "$flake_dir/flake.nix" ]] && grep -q "darwin" "$flake_dir/flake.nix" 2> /dev/null; then
    # Flake-based darwin configuration
    echo "Detected flake-based darwin configuration"

    case "$CHECK_MODE" in
      check)
        if ! darwin-rebuild check --flake "$flake_dir" 2>&1; then
          echo "ERROR: Darwin configuration check failed for $file"
          PASS=false
        else
          echo "✓ Darwin configuration check passed for $file"
        fi
        ;;
      dry-build)
        if ! darwin-rebuild build --dry-run --flake "$flake_dir" 2>&1; then
          echo "ERROR: Darwin dry-build failed for $file"
          PASS=false
        else
          echo "✓ Darwin dry-build passed for $file"
        fi
        ;;
    esac
  else
    # Legacy darwin configuration
    echo "Detected legacy darwin configuration"

    # Create a temporary configuration that imports the file
    temp_config="$(mktemp -t darwin-check.XXXXXX.nix)"
    cat > "$temp_config" << EOF
{ config, pkgs, ... }:
{
  imports = [ $file ];
}
EOF

    case "$CHECK_MODE" in
      check)
        if ! darwin-rebuild check -I "darwin-config=$temp_config" 2>&1; then
          echo "ERROR: Darwin configuration check failed for $file"
          PASS=false
        else
          echo "✓ Darwin configuration check passed for $file"
        fi
        ;;
      dry-build)
        if ! darwin-rebuild build --dry-run -I "darwin-config=$temp_config" 2>&1; then
          echo "ERROR: Darwin dry-build failed for $file"
          PASS=false
        else
          echo "✓ Darwin dry-build passed for $file"
        fi
        ;;
    esac

    rm -f "$temp_config"
  fi
done

if ! $PASS; then
  exit 1
fi
