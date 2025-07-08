# Pre-commit Hook Development Guide

## Table of Contents
1. [Introduction](#introduction)
2. [Hook Architecture](#hook-architecture)
3. [Writing Your First Hook](#writing-your-first-hook)
4. [Best Practices](#best-practices)
5. [Testing Hooks](#testing-hooks)
6. [Security Guidelines](#security-guidelines)
7. [Common Patterns](#common-patterns)
8. [Troubleshooting](#troubleshooting)

## Introduction

Pre-commit hooks are scripts that run automatically before a commit is made to ensure code quality, consistency, and security. This guide will help you develop robust, secure, and efficient hooks for this repository.

## Hook Architecture

### Directory Structure
```
hooks/
├── ci/           # CI/CD related hooks
├── commits/      # Commit message hooks
├── configs/      # Configuration file hooks
├── nix/          # Nix-specific hooks
├── terraform/    # Terraform hooks
├── web/          # Web development hooks
│   ├── css/      # CSS linting
│   ├── js/       # JavaScript tools
│   └── scss/     # SCSS linting
└── ...           # Other categories
```

### Hook Anatomy

Every hook should follow this basic structure:

```bash
#!/usr/bin/env bash

# 1. Set error handling
set -euo pipefail

# 2. Define help text
show_help() {
  cat << EOF
Hook: your-hook-name
Purpose: Brief description of what this hook does
Usage: your-hook.sh [options] [files...]

Options:
  -h, --help    Show this help message
  -v, --verbose Enable verbose output
EOF
}

# 3. Check dependencies
check_dependencies() {
  if ! command -v required-tool &> /dev/null; then
    echo "Error: required-tool is not installed"
    echo "Install with: [installation command]"
    exit 1
  fi
}

# 4. Main logic
main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        exit 0
        ;;
      -v|--verbose)
        VERBOSE=1
        shift
        ;;
      *)
        FILES+=("$1")
        shift
        ;;
    esac
  done

  # Check dependencies
  check_dependencies

  # Process files
  for file in "${FILES[@]}"; do
    process_file "$file"
  done
}

# 5. Run main
main "$@"
```

## Writing Your First Hook

### Step 1: Create the Hook File

```bash
# Create hook file
touch hooks/category/my-hook.sh
chmod +x hooks/category/my-hook.sh
```

### Step 2: Implement Core Functionality

```bash
#!/usr/bin/env bash

set -euo pipefail

# Simple example: Check file size
MAX_SIZE=1048576  # 1MB

for file in "$@"; do
  if [[ -f "$file" ]]; then
    size=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file")
    if [[ $size -gt $MAX_SIZE ]]; then
      echo "Error: $file exceeds maximum size ($size > $MAX_SIZE bytes)"
      exit 1
    fi
  fi
done

echo "All files pass size check"
```

### Step 3: Add Error Handling

```bash
# Trap errors and clean up
cleanup() {
  local exit_code=$?
  # Clean up temporary files
  rm -f "$TEMP_FILE"
  exit $exit_code
}

trap cleanup EXIT ERR
```

## Best Practices

### 1. Input Validation
Always validate and sanitize inputs:

```bash
# Good: Quote variables
process_file "$file"

# Bad: Unquoted variable
process_file $file

# Good: Validate file exists
if [[ ! -f "$file" ]]; then
  echo "Error: File not found: $file"
  exit 1
fi
```

### 2. Dependency Management
Check for required tools:

```bash
# Check if in npm project
if [[ -f "package.json" ]]; then
  # Use local installation
  npx eslint "$@"
else
  # Install globally or fail gracefully
  if ! command -v eslint &> /dev/null; then
    echo "Installing eslint..."
    npm install -g eslint
  fi
  eslint "$@"
fi
```

### 3. Exit Codes
Use consistent exit codes:
- `0`: Success
- `1`: General error
- `2`: Misuse of shell command
- `126`: Command cannot execute
- `127`: Command not found

### 4. Progress Feedback
Provide clear feedback:

```bash
# Show progress for long operations
echo "Processing ${#FILES[@]} files..."

for i in "${!FILES[@]}"; do
  echo "[$((i+1))/${#FILES[@]}] Processing ${FILES[$i]}"
  process_file "${FILES[$i]}"
done
```

## Testing Hooks

### 1. Create Test File
Create `tests/category/test_my_hook.bats`:

```bash
#!/usr/bin/env bats

load ../test_helper

setup() {
  setup_test_env
}

teardown() {
  teardown_test_env
}

@test "hook exists and is executable" {
  run test -x "$ORIGINAL_DIR/hooks/category/my-hook.sh"
  [ "$status" -eq 0 ]
}

@test "hook validates input correctly" {
  create_test_file "test.txt" "content"

  run "$ORIGINAL_DIR/hooks/category/my-hook.sh" "test.txt"
  [ "$status" -eq 0 ]
}

@test "hook fails on invalid input" {
  run "$ORIGINAL_DIR/hooks/category/my-hook.sh" "nonexistent.txt"
  [ "$status" -eq 1 ]
  [[ "$output" =~ "not found" ]]
}
```

### 2. Run Tests

```bash
# Run single test
bats tests/category/test_my_hook.bats

# Run all tests
./tests/run_tests.sh
```

## Security Guidelines

### 1. Command Injection Prevention
```bash
# Bad: Direct interpolation
eval "command $user_input"

# Good: Use arrays
cmd=("command" "$user_input")
"${cmd[@]}"
```

### 2. Path Traversal Protection
```bash
# Validate paths
realpath=$(readlink -f "$file")
if [[ ! "$realpath" =~ ^"$(pwd)" ]]; then
  echo "Error: Path traversal attempt"
  exit 1
fi
```

### 3. Temporary File Security
```bash
# Create secure temp files
TEMP_FILE=$(mktemp)
trap 'rm -f "$TEMP_FILE"' EXIT

# Set restrictive permissions
chmod 600 "$TEMP_FILE"
```

## Common Patterns

### 1. Processing Multiple Files
```bash
# Process files in parallel
process_files() {
  local pids=()

  for file in "$@"; do
    process_file "$file" &
    pids+=($!)
  done

  # Wait for all processes
  for pid in "${pids[@]}"; do
    wait "$pid" || exit_code=$?
  done

  return ${exit_code:-0}
}
```

### 2. Configuration Handling
```bash
# Load configuration
CONFIG_FILE="${HOME}/.hookconfig"
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
fi

# Use defaults
MAX_SIZE="${MAX_SIZE:-1048576}"
VERBOSE="${VERBOSE:-0}"
```

### 3. Cross-Platform Compatibility
```bash
# Handle different stat commands
get_file_size() {
  local file=$1
  if [[ "$OSTYPE" == "darwin"* ]]; then
    stat -f%z "$file"
  else
    stat -c%s "$file"
  fi
}
```

## Troubleshooting

### Common Issues

1. **Hook not executable**
   ```bash
   chmod +x hooks/category/my-hook.sh
   ```

2. **Command not found**
   ```bash
   # Add to PATH or use full path
   export PATH="/usr/local/bin:$PATH"
   ```

3. **Permission denied**
   ```bash
   # Check file permissions
   ls -la hooks/category/my-hook.sh
   ```

### Debugging Tips

1. **Enable debug mode**
   ```bash
   set -x  # Print commands as executed
   ```

2. **Add logging**
   ```bash
   debug() {
     [[ $VERBOSE -eq 1 ]] && echo "DEBUG: $*" >&2
   }
   ```

3. **Test in isolation**
   ```bash
   # Test hook directly
   ./hooks/category/my-hook.sh test-file.txt
   ```

## Contributing

When contributing a new hook:

1. Follow the directory structure
2. Include comprehensive tests
3. Document dependencies
4. Add usage examples
5. Ensure cross-platform compatibility
6. Run all tests before submitting

## Examples

See existing hooks for examples:
- Simple: `hooks/configs/yamlfmt.sh`
- Complex: `hooks/witness.sh`
- With dependencies: `hooks/nix/nix-build.sh`

## Resources

- [Bash Best Practices](https://google.github.io/styleguide/shellguide.html)
- [Pre-commit Documentation](https://pre-commit.com/)
- [ShellCheck](https://www.shellcheck.net/)
- [Bats Testing](https://github.com/bats-core/bats-core)
