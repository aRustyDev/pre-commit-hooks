# Pre-commit Hooks Project Documentation

## Overview

This repository provides a comprehensive collection of pre-commit hooks for various programming languages and tools. Pre-commit hooks help maintain code quality by automatically checking and fixing issues before commits are made.

## Installation

### Prerequisites
- Git 2.x or higher
- Python 3.6+ (for pre-commit framework)
- Target language tools (varies by hook)

### Quick Start

1. **Install pre-commit framework**:
   ```bash
   pip install pre-commit
   # or
   brew install pre-commit
   # or
   nix-env -iA nixpkgs.pre-commit
   ```

2. **Add to your project**:
   Create `.pre-commit-config.yaml` in your repository:
   ```yaml
   repos:
     - repo: https://github.com/aRustyDev/pre-commit-hooks
       rev: v0.3.0
       hooks:
         - id: nix-fmt
         - id: dead-links
         - id: cargo-check
   ```

3. **Install the git hook scripts**:
   ```bash
   pre-commit install
   ```

4. **Run hooks manually** (optional):
   ```bash
   pre-commit run --all-files
   ```

## Configuration

### Global Configuration

Hooks can be configured via environment variables:

```bash
# Example: Configure Nix formatter
export NIX_FORMATTER=alejandra

# Example: Enable dry-run mode
export NIX_BUILD_DRY_RUN=true

# Example: Add custom arguments
export NIX_BUILD_ARGS="--option sandbox false"
```

### Per-Hook Configuration

In `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      - id: nix-fmt
        args: [--formatter=nixpkgs-fmt]
      - id: nix-lint
        args: [--with-deadnix]
      - id: dead-links
        files: ^docs/.*\.md$  # Only check docs
```

### Advanced Configuration

#### Stages
Run hooks at different git stages:
```yaml
- id: commitizen
  stages: [commit-msg]
- id: cargo-test
  stages: [push]
```

#### Conditional Execution
```yaml
- id: nix-darwin-check
  # Only runs on Darwin/macOS automatically
```

#### Custom File Patterns
```yaml
- id: nix-build-check
  files: ^myproject/.*\.nix$
```

## Usage Examples

### Basic Usage
After installation, hooks run automatically on `git commit`:
```bash
$ git add .
$ git commit -m "feat: add new feature"
nix-fmt..........................................................Passed
dead-links.......................................................Passed
cargo-check......................................................Passed
```

### Manual Execution
Run specific hooks:
```bash
# Run single hook
pre-commit run nix-fmt

# Run on specific files
pre-commit run nix-fmt --files src/config.nix

# Run all hooks
pre-commit run --all-files
```

### Skipping Hooks
```bash
# Skip all hooks
git commit --no-verify

# Skip in environment
SKIP=nix-fmt,dead-links git commit
```

## Troubleshooting

### Common Issues

#### 1. Command not found
**Problem**: Hook fails with "command is not installed"
**Solution**: Install the required tool or let the hook auto-install it

#### 2. Hook takes too long
**Problem**: Hook times out or runs slowly
**Solutions**:
- Use file filters to limit scope
- Enable parallel execution
- Use dry-run modes where available

#### 3. Permission denied
**Problem**: Hook fails with permission errors
**Solution**: No hook should require sudo. Check file permissions and ensure tools are user-installed.

#### 4. Platform incompatibility
**Problem**: Hook fails on your OS
**Solution**: Check hook documentation for platform support. Some hooks (like nix-darwin-check) are platform-specific.

### Debug Mode
Enable verbose output:
```bash
pre-commit run --verbose nix-fmt
```

Check hook configuration:
```bash
pre-commit run --show-diff-on-failure
```

## Contributing

### Adding a New Hook

1. **Read the rules**: Review [`HOOK_RULES.md`](../HOOK_RULES.md)

2. **Create hook script**:
   ```bash
   # Create in appropriate directory
   touch hooks/category/my-hook.sh
   chmod +x hooks/category/my-hook.sh
   ```

3. **Implement following standards**:
   ```bash
   #!/usr/bin/env bash

   # Check dependencies
   if ! command -v my-tool &> /dev/null; then
     echo "my-tool is not installed"
     exit 1
   fi

   # Process files
   PASS=true
   for file in "$@"; do
     if ! my-tool "$file"; then
       PASS=false
     fi
   done

   if ! $PASS; then
     exit 1
   fi
   ```

4. **Add to .pre-commit-hooks.yaml**:
   ```yaml
   - id: my-hook
     name: My Hook Description
     description: What this hook does
     entry: hooks/category/my-hook.sh
     language: script
     files: \.ext$
   ```

5. **Add tests**:
   ```bash
   mkdir -p tests/category/fixtures
   # Add test files
   ```

6. **Document**: Update relevant documentation files

### Testing Hooks

1. **Manual testing**:
   ```bash
   ./hooks/category/my-hook.sh tests/category/fixtures/test.ext
   ```

2. **Integration testing**:
   ```bash
   pre-commit try-repo . my-hook --files tests/category/fixtures/test.ext
   ```

3. **CI testing**: Ensure GitHub Actions pass

### Pull Request Process

1. Fork the repository
2. Create feature branch: `git checkout -b feature/new-hook`
3. Implement and test your hook
4. Update documentation
5. Submit PR with:
   - Clear description
   - Test results
   - Documentation updates

## Architecture

### Directory Structure
```
.
├── .pre-commit-hooks.yaml    # Hook definitions
├── hooks/                    # Hook implementations
│   ├── backup-nixos.sh
│   ├── ci/
│   ├── commits/
│   ├── configs/
│   ├── docs/
│   ├── nix/
│   ├── terraform/
│   └── web/
├── tests/                    # Test fixtures
├── .claude/                  # AI context docs
│   ├── CLAUDE.md
│   ├── HOOK_RULES.md
│   └── docs/
└── TODO.md                   # Roadmap
```

### Hook Lifecycle
1. Pre-commit framework invokes hook
2. Hook receives file list as arguments
3. Hook processes each file
4. Hook exits with 0 (success) or 1 (failure)
5. Pre-commit reports results

### Design Principles
- **No sudo required**: User-space operation only
- **Auto-installation**: Reduce setup friction
- **Clear errors**: Actionable error messages
- **Fast execution**: Minimize commit delays
- **Cross-platform**: Support major platforms

## Versioning

This project follows [Semantic Versioning](https://semver.org/):
- **MAJOR**: Breaking changes to hook behavior
- **MINOR**: New hooks or features
- **PATCH**: Bug fixes and minor improvements

Always pin to a specific version in your `.pre-commit-config.yaml`:
```yaml
rev: v0.3.0  # Pin to specific version
```

## License

[Check repository for license information]

## Support

- **Issues**: [GitHub Issues](https://github.com/aRustyDev/pre-commit-hooks/issues)
- **Discussions**: [GitHub Discussions](https://github.com/aRustyDev/pre-commit-hooks/discussions)
- **Updates**: Watch the repository for new releases

## Roadmap

See [`TODO.md`](../../TODO.md) for planned features and improvements.

---
*For specific hook documentation, see the category-specific docs in this directory.*
