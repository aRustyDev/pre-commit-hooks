#!/usr/bin/env bash

# Check for required commands
for cmd in nix home-manager; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$cmd is not installed"
    echo "Please install home-manager: https://github.com/nix-community/home-manager"
    exit 1
  fi
done

PASS=true
DRY_RUN="${HOME_MANAGER_DRY_RUN:-true}"

# Process each file
for file in "$@"; do
  # Skip non-nix files
  if [[ ! "$file" =~ \.nix$ ]]; then
    continue
  fi

  # Skip files that don't look like home-manager configurations
  if ! grep -q "home\|users\|programs\|services" "$file" 2> /dev/null; then
    continue
  fi

  echo "Checking home-manager configuration: $file..."

  # Determine if this is a flake-based home-manager config
  flake_dir="$(dirname "$file")"
  if [[ -f "$flake_dir/flake.nix" ]] && grep -q "home-manager" "$flake_dir/flake.nix" 2> /dev/null; then
    # Flake-based home-manager configuration
    echo "Detected flake-based home-manager configuration"

    # Try to find the home configuration name from the flake
    # This is a simple heuristic and may need adjustment based on your flake structure
    if [[ "$DRY_RUN" == "true" ]]; then
      if ! home-manager build --flake "$flake_dir" --dry-run 2>&1; then
        echo "ERROR: Home-manager configuration check failed for $file"
        PASS=false
      else
        echo "✓ Home-manager configuration check passed for $file"
      fi
    else
      if ! home-manager build --flake "$flake_dir" 2>&1; then
        echo "ERROR: Home-manager build failed for $file"
        PASS=false
      else
        echo "✓ Home-manager build passed for $file"
      fi
    fi
  else
    # Legacy home-manager configuration or module
    echo "Detected legacy home-manager configuration"

    # Create a temporary configuration that imports the file
    temp_config="$(mktemp -t home-manager-check.XXXXXX.nix)"

    # Check if this is a full configuration or a module
    if grep -q "home.username\|home.homeDirectory" "$file" 2> /dev/null; then
      # This looks like a complete home configuration
      cp "$file" "$temp_config"
    else
      # This looks like a module, wrap it
      cat > "$temp_config" << EOF
{ config, pkgs, ... }:
{
  imports = [ $file ];

  # Minimal required configuration for home-manager
  home.username = "test-user";
  home.homeDirectory = "/tmp/test-home";
  home.stateVersion = "23.11";  # Adjust as needed
}
EOF
    fi

    if [[ "$DRY_RUN" == "true" ]]; then
      if ! home-manager build -f "$temp_config" -n 2>&1; then
        echo "ERROR: Home-manager configuration check failed for $file"
        PASS=false
      else
        echo "✓ Home-manager configuration check passed for $file"
      fi
    else
      if ! home-manager build -f "$temp_config" 2>&1; then
        echo "ERROR: Home-manager build failed for $file"
        PASS=false
      else
        echo "✓ Home-manager build passed for $file"
      fi
    fi

    rm -f "$temp_config"
  fi
done

if ! $PASS; then
  exit 1
fi
