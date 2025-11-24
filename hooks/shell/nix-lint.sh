#!/usr/bin/env bash

# Configuration
WITH_DEADNIX="${NIX_LINT_WITH_DEADNIX:-false}"
STATIX_CONFIG="${STATIX_CONFIG:-}"
DEADNIX_NO_LAMBDA_ARG="${DEADNIX_NO_LAMBDA_ARG:-false}"
DEADNIX_NO_UNDERSCORE="${DEADNIX_NO_UNDERSCORE:-false}"

# Function to install linter if not available
install_linter() {
  local linter="$1"
  echo "Installing $linter..."

  case "$linter" in
    statix)
      nix-env -iA nixpkgs.statix || nix profile install nixpkgs#statix
      ;;
    deadnix)
      nix-env -iA nixpkgs.deadnix || nix profile install nixpkgs#deadnix
      ;;
    *)
      echo "Unknown linter: $linter"
      return 1
      ;;
  esac
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --with-deadnix)
      WITH_DEADNIX="true"
      shift
      ;;
    --statix-config=*)
      STATIX_CONFIG="${1#*=}"
      shift
      ;;
    --no-lambda-arg)
      DEADNIX_NO_LAMBDA_ARG="true"
      shift
      ;;
    --no-underscore)
      DEADNIX_NO_UNDERSCORE="true"
      shift
      ;;
    *)
      break
      ;;
  esac
done

# Check if statix is installed
if ! command -v statix &> /dev/null; then
  echo "statix is not installed"

  # Try to install it
  if ! install_linter statix; then
    exit 1
  fi

  # Check again
  if ! command -v statix &> /dev/null; then
    echo "Failed to install statix"
    exit 1
  fi
fi

# Check if deadnix is needed and installed
if [[ "$WITH_DEADNIX" == "true" ]]; then
  if ! command -v deadnix &> /dev/null; then
    echo "deadnix is not installed"

    # Try to install it
    if ! install_linter deadnix; then
      exit 1
    fi

    # Check again
    if ! command -v deadnix &> /dev/null; then
      echo "Failed to install deadnix"
      exit 1
    fi
  fi
fi

PASS=true

# Process each file
for file in "$@"; do
  # Skip non-nix files
  if [[ ! "$file" =~ \.nix$ ]]; then
    continue
  fi

  echo "Linting $file..."

  # Run statix
  STATIX_ARGS=""
  if [[ -n "$STATIX_CONFIG" ]]; then
    STATIX_ARGS="--config $STATIX_CONFIG"
  fi

  # shellcheck disable=SC2086
  if ! statix check $STATIX_ARGS "$file" 2>&1; then
    echo "ERROR: statix found issues in $file"
    PASS=false
  else
    echo "✓ statix check passed for $file"
  fi

  # Run deadnix if requested
  if [[ "$WITH_DEADNIX" == "true" ]]; then
    DEADNIX_ARGS=""

    if [[ "$DEADNIX_NO_LAMBDA_ARG" == "true" ]]; then
      DEADNIX_ARGS="$DEADNIX_ARGS --no-lambda-arg"
    fi

    if [[ "$DEADNIX_NO_UNDERSCORE" == "true" ]]; then
      DEADNIX_ARGS="$DEADNIX_ARGS --no-underscore"
    fi

    # deadnix returns 0 even when it finds issues, so we check its output
    # shellcheck disable=SC2086
    deadnix_output="$(deadnix $DEADNIX_ARGS "$file" 2>&1)"

    if [[ -n "$deadnix_output" ]]; then
      echo "ERROR: deadnix found dead code in $file:"
      echo "$deadnix_output"
      PASS=false
    else
      echo "✓ deadnix check passed for $file"
    fi
  fi
done

if ! $PASS; then
  echo ""
  echo "Lint issues found. To automatically fix some issues, run:"
  echo "  statix fix <file>"
  if [[ "$WITH_DEADNIX" == "true" ]]; then
    echo "  deadnix -e <file>  # to edit and remove dead code"
  fi
  exit 1
fi
