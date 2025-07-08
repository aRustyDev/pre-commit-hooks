# Hook Development Rules

This document outlines the rules and best practices for developing pre-commit hooks in this repository.

## Core Rules

### 1. NO SUDO REQUIREMENT ⚠️
**CRITICAL**: No hook shall require sudo or elevated privileges to function.
- Hooks must work in user space
- If system-level access is needed, document alternatives
- Never prompt for passwords or elevated access
- If a tool requires sudo for installation, provide user-space alternatives

### 2. Dependency Management
- **Check before use**: Always verify commands exist before executing
- **Auto-install when possible**: Attempt to install missing tools automatically
- **Clear instructions**: If auto-install fails, provide manual installation steps
- **Fallback gracefully**: If tool cannot be installed, exit with clear error

### 3. Script Structure Requirements
Every hook script MUST follow this structure:

```bash
#!/usr/bin/env bash

# 1. Dependency checks
for cmd in required_command1 required_command2; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "$cmd is not installed"
    # Attempt auto-install or provide instructions
    exit 1
  fi
done

# 2. Configuration
OPTION_VAR="${ENV_VAR:-default_value}"

# 3. Initialize state
PASS=true

# 4. Process files
for file in "$@"; do
  # Process each file
  if ! process_file "$file"; then
    PASS=false
  fi
done

# 5. Exit appropriately
if ! $PASS; then
  exit 1
fi
```

### 4. Error Handling
- **Always check return codes**: Use `if ! command; then` pattern
- **Provide context**: Include filename and line numbers in errors
- **Be specific**: "Syntax error in file.py:42" not "Error in file"
- **Suggest fixes**: Where possible, tell users how to fix issues

### 5. Configuration Standards
- **Environment variables**: Use SCREAMING_SNAKE_CASE prefixed with hook name
  - Example: `NIX_FMT_FORMATTER`, `TERRAFORM_VALIDATE_ARGS`
- **Arguments**: Support both `--flag value` and `--flag=value` formats
- **Defaults**: Always provide sensible defaults
- **Documentation**: List all options in hook description

### 6. File Processing
- **Handle multiple files**: Process all files passed as arguments
- **Skip irrelevant files**: Check file extensions/patterns before processing
- **Preserve formatting**: Don't modify files unless explicitly a formatting hook
- **Atomic operations**: Use temp files for modifications, then move

### 7. Output Standards
- **Be concise**: Only output on errors or when changes are made
- **Use indicators**: ✓ for success, ✗ or ERROR: for failures
- **Progress for long operations**: Show file being processed
- **Summary at end**: "Processed X files, Y passed, Z failed"

### 8. Platform Compatibility
- **Check platform when needed**: Use `uname` for OS-specific behavior
- **Document limitations**: If hook only works on certain platforms
- **Graceful degradation**: Skip cleanly on unsupported platforms
- **Test on multiple platforms**: At minimum Linux and macOS

### 9. Performance Considerations
- **Process files individually**: Allow pre-commit to parallelize
- **Avoid redundant work**: Cache results when appropriate
- **Quick fail**: Exit early on first error if `--fail-fast` behavior
- **Reasonable timeouts**: Long-running operations should have limits

### 10. Testing Requirements
- **Provide test fixtures**: Include sample files in `tests/` directory
- **Test success cases**: Valid files should pass
- **Test failure cases**: Invalid files should fail with clear errors
- **Test edge cases**: Empty files, missing files, permission issues
- **Document test commands**: Show how to manually test the hook

### 11. Documentation Standards
Each hook MUST be documented with:
- **Purpose**: What the hook does
- **File patterns**: What files it processes
- **Dependencies**: Required tools and versions
- **Configuration**: All environment variables and arguments
- **Examples**: Common usage patterns
- **Limitations**: Known issues or platform restrictions

### 12. Security Considerations
- **No credential storage**: Never store or log sensitive information
- **Validate inputs**: Sanitize file paths and user inputs
- **Safe command execution**: Use proper quoting to prevent injection
- **Temporary file security**: Use `mktemp` for temporary files
- **Clean up resources**: Remove temporary files on exit

### 13. Versioning and Compatibility
- **Tool version checks**: Verify minimum required versions
- **Backward compatibility**: Don't break existing configurations
- **Deprecation notices**: Warn before removing features
- **Version documentation**: Note which tool versions are supported

### 14. Language-Specific Rules

#### Shell Scripts
- **Use `shellcheck`**: All scripts must pass shellcheck
- **Prefer POSIX**: Use `/usr/bin/env bash` for consistency
- **Quote variables**: Always quote unless word splitting needed
- **Use `set -euo pipefail`**: For development, not in hooks

#### Python Hooks
- **Python 3.6+**: Assume modern Python
- **No pip installs**: Use system packages or user instructions
- **Virtual env aware**: Respect activated virtual environments

#### Node.js Hooks
- **Check npm/yarn**: Support both package managers
- **Local vs global**: Prefer local node_modules/.bin
- **Version checks**: Verify Node.js version if needed

### 15. Hook Metadata Requirements
In `.pre-commit-hooks.yaml`:
- **Unique ID**: Descriptive, lowercase, hyphenated
- **Clear name**: Human-readable, title case
- **Description**: One-line summary of functionality
- **Entry point**: Path to script from repo root
- **File patterns**: Use appropriate `files` or `types`
- **Language**: Usually `script` for shell scripts
- **Pass filenames**: Set to `true` unless processing all files

### 16. Common Antipatterns to Avoid
- ❌ Using `sudo` or requiring root access
- ❌ Modifying files without being a formatter
- ❌ Silently failing without error messages
- ❌ Hardcoding paths (/usr/bin/tool)
- ❌ Assuming tool installation locations
- ❌ Breaking on spaces in filenames
- ❌ Outputting debug info in normal operation
- ❌ Taking too long without progress indication
- ❌ Leaving temporary files behind
- ❌ Using deprecated tool options

### 17. Special Considerations

#### Auto-installation
When implementing auto-installation:
1. Check if tool exists first
2. Try package manager in order: nix, brew, apt, etc.
3. Fall back to language-specific: pip, npm, cargo
4. Always inform user what's being installed
5. Never force installation without consent

#### Cross-Repository Usage
Hooks should work when:
- Repository is cloned to any location
- User has different shell configurations
- Running in CI/CD environments
- Used as a git submodule

### 18. Review Checklist
Before submitting a new hook:
- [ ] No sudo required anywhere
- [ ] Follows standard script structure
- [ ] Handles missing dependencies
- [ ] Clear error messages
- [ ] Supports configuration
- [ ] Has test fixtures
- [ ] Documented in hook file
- [ ] Added to .pre-commit-hooks.yaml
- [ ] Tested on Linux and macOS
- [ ] Passes shellcheck (if shell script)
- [ ] No hardcoded paths
- [ ] Cleans up temporary files
- [ ] Respects user's environment

## Examples

### Good Hook Example
```bash
#!/usr/bin/env bash

# Check for required commands
for cmd in example-tool; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "ERROR: $cmd is not installed"
    echo "Install with: brew install example-tool"
    exit 1
  fi
done

# Configuration
EXAMPLE_OPTION="${EXAMPLE_OPTION:-default}"

# Process files
PASS=true
for file in "$@"; do
  echo "Checking $file..."
  if ! example-tool "$file" --option="$EXAMPLE_OPTION"; then
    echo "ERROR: Failed to process $file"
    PASS=false
  fi
done

if ! $PASS; then
  exit 1
fi
```

### Bad Hook Example
```bash
#!/bin/bash
# ❌ Missing /usr/bin/env
# ❌ No dependency check
# ❌ Requires sudo
sudo example-tool $@  # ❌ Unquoted $@
# ❌ No error handling
# ❌ No configuration options
```

Remember: The goal is to make hooks that are reliable, portable, and user-friendly!
