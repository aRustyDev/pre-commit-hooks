#!/usr/bin/env bash

# Default formatter
FORMATTER="${NIX_FORMATTER:-nixpkgs-fmt}"
CHECK_MODE="${NIX_FMT_CHECK:-false}"

# Function to install formatter if not available
install_formatter() {
  local formatter="$1"
  echo "Installing $formatter..."

  case "$formatter" in
    nixpkgs-fmt)
      nix-env -iA nixpkgs.nixpkgs-fmt || nix profile install nixpkgs#nixpkgs-fmt
      ;;
    alejandra)
      nix-env -iA nixpkgs.alejandra || nix profile install nixpkgs#alejandra
      ;;
    nixfmt)
      nix-env -iA nixpkgs.nixfmt || nix profile install nixpkgs#nixfmt
      ;;
    *)
      echo "Unknown formatter: $formatter"
      return 1
      ;;
  esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --formatter=*)
      FORMATTER="${1#*=}"
      shift
      ;;
    --formatter)
      FORMATTER="$2"
      shift 2
      ;;
    --check)
      CHECK_MODE="true"
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Check if formatter is installed
if ! command -v "$FORMATTER" &> /dev/null; then
  echo "$FORMATTER is not installed"

  # Try to install it
  if ! install_formatter "$FORMATTER"; then
    exit 1
  fi

  # Check again
  if ! command -v "$FORMATTER" &> /dev/null; then
    echo "Failed to install $FORMATTER"
    exit 1
  fi
fi

PASS=true

# Process each file
for file in "$@"; do
  # Skip non-nix files
  if [[ ! "$file" =~ \.nix$ ]]; then
    continue
  fi

  if [[ "$CHECK_MODE" == "true" ]]; then
    # Check mode - verify if file is formatted
    echo "Checking format of $file..."

    # Create a temporary file with formatted content
    temp_file="$(mktemp -t nix-fmt-check.XXXXXX.nix)"

    case "$FORMATTER" in
      nixpkgs-fmt)
        nixpkgs-fmt "$file" > "$temp_file" 2> /dev/null
        ;;
      alejandra)
        alejandra "$file" -q > "$temp_file" 2> /dev/null
        ;;
      nixfmt)
        nixfmt < "$file" > "$temp_file" 2> /dev/null
        ;;
    esac

    # Compare with original
    if ! diff -q "$file" "$temp_file" > /dev/null 2>&1; then
      echo "ERROR: $file is not properly formatted"
      echo "Run '$FORMATTER $file' to format it"
      PASS=false
    else
      echo "✓ $file is properly formatted"
    fi

    rm -f "$temp_file"
  else
    # Format mode - format file in place
    echo "Formatting $file with $FORMATTER..."

    case "$FORMATTER" in
      nixpkgs-fmt)
        if ! nixpkgs-fmt "$file" 2>&1; then
          echo "ERROR: Failed to format $file"
          PASS=false
        else
          echo "✓ Formatted $file"
        fi
        ;;
      alejandra)
        if ! alejandra "$file" -q 2>&1; then
          echo "ERROR: Failed to format $file"
          PASS=false
        else
          echo "✓ Formatted $file"
        fi
        ;;
      nixfmt)
        # nixfmt doesn't support in-place editing
        temp_file="$(mktemp -t nix-fmt.XXXXXX.nix)"
        if nixfmt < "$file" > "$temp_file" 2>&1; then
          mv "$temp_file" "$file"
          echo "✓ Formatted $file"
        else
          echo "ERROR: Failed to format $file"
          rm -f "$temp_file"
          PASS=false
        fi
        ;;
    esac
  fi
done

if ! $PASS; then
  exit 1
fi
