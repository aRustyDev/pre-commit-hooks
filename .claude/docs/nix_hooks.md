# Nix Ecosystem Hooks

This document covers all Nix-related pre-commit hooks provided by this repository.

## Available Hooks

### nix-flake-check

**Purpose**: Validates Nix flakes using `nix flake check`

**File Pattern**: `flake.nix`

**Configuration**:
- `NIX_FLAKE_SHOW`: Set to "true" to show flake structure (default: false)

**Example**:
```yaml
- id: nix-flake-check
```

**Features**:
- Automatically detects flake.nix files
- Checks for experimental features
- Validates flake outputs
- Optional flake structure display

**Common Issues**:
- "Nix flakes experimental feature is not enabled" - Add to nix.conf:
  ```
  experimental-features = nix-command flakes
  ```

---

### nix-build-check

**Purpose**: Tests that Nix expressions build successfully

**File Pattern**: `(default|shell)\.nix$`

**Configuration**:
- `NIX_BUILD_DRY_RUN`: Set to "true" for dry-run only (default: false)
- `NIX_BUILD_ARGS`: Additional arguments to pass to nix-build

**Example**:
```yaml
- id: nix-build-check
  env:
    - NIX_BUILD_DRY_RUN=true
```

**Features**:
- Supports both flakes and legacy Nix expressions
- Dry-run mode for faster checks
- Handles flake.nix differently from other .nix files
- Configurable build arguments

**Common Issues**:
- Long build times: Use `NIX_BUILD_DRY_RUN=true`
- Sandbox errors: Add `--option sandbox false` to `NIX_BUILD_ARGS`

---

### nix-darwin-check

**Purpose**: Validates nix-darwin configurations

**File Pattern**: `darwin.*\.nix$`

**Platform**: macOS only (automatically skips on other platforms)

**Configuration**:
- `DARWIN_CHECK_MODE`: "check" or "dry-build" (default: check)

**Example**:
```yaml
- id: nix-darwin-check
  env:
    - DARWIN_CHECK_MODE=dry-build
```

**Features**:
- Platform detection (macOS only)
- Supports both flake and legacy configurations
- Two validation modes
- Automatic configuration detection

**Requirements**:
- nix-darwin must be installed
- Only runs on Darwin/macOS systems

---

### nix-home-manager-check

**Purpose**: Validates home-manager configurations

**File Pattern**: `(home|users/.*|home-manager/.*)\.nix$`

**Configuration**:
- `HOME_MANAGER_DRY_RUN`: Set to "false" for full build (default: true)

**Example**:
```yaml
- id: nix-home-manager-check
  files: ^modules/home/.*\.nix$
```

**Features**:
- Detects both standalone and module configurations
- Supports flake-based home-manager
- Wraps partial modules for testing
- Dry-run by default for speed

**Common Issues**:
- "home-manager is not installed" - Install via:
  ```bash
  nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
  ```

---

### nix-fmt

**Purpose**: Formats Nix files using various formatters

**File Pattern**: `\.nix$`

**Configuration**:
- `NIX_FORMATTER`: Formatter choice (default: nixpkgs-fmt)
  - Options: nixpkgs-fmt, alejandra, nixfmt
- `NIX_FMT_CHECK`: Set to "true" for check-only mode

**Arguments**:
- `--formatter=<name>`: Choose formatter
- `--check`: Check mode (don't modify files)

**Example**:
```yaml
- id: nix-fmt
  args: [--formatter=alejandra]
```

**Features**:
- Multiple formatter support
- Auto-installs formatter if missing
- Check mode for CI
- Preserves file structure

**Formatter Comparison**:
- **nixpkgs-fmt**: Official, conservative formatting
- **alejandra**: Opinionated, strict formatting
- **nixfmt**: Classic formatter, different style

---

### nix-lint

**Purpose**: Lints Nix files for anti-patterns and dead code

**File Pattern**: `\.nix$`

**Configuration**:
- `NIX_LINT_WITH_DEADNIX`: Enable deadnix (default: false)
- `STATIX_CONFIG`: Path to statix config file
- `DEADNIX_NO_LAMBDA_ARG`: Disable lambda arg check
- `DEADNIX_NO_UNDERSCORE`: Disable underscore check

**Arguments**:
- `--with-deadnix`: Enable dead code detection
- `--statix-config=<path>`: Custom statix config
- `--no-lambda-arg`: For deadnix
- `--no-underscore`: For deadnix

**Example**:
```yaml
- id: nix-lint
  args: [--with-deadnix]
```

**Features**:
- statix for anti-pattern detection
- Optional deadnix integration
- Auto-installs linters
- Provides fix suggestions

**Common Warnings**:
- "Assignment instead of inherit" - Use `inherit` syntax
- "Dead code found" - Remove unused bindings

---

### nixos-build

**Purpose**: Builds NixOS packages

**File Pattern**: `packages\.nix$`

**Note**: This is a legacy hook. Consider using `nix-build-check` instead.

**Example**:
```yaml
- id: nixos-build
```

---

## Installation Tips

### Global Nix Setup

1. **Enable flakes** (for flake-related hooks):
   ```bash
   mkdir -p ~/.config/nix
   echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
   ```

2. **Install formatters/linters globally**:
   ```bash
   nix profile install nixpkgs#nixpkgs-fmt nixpkgs#statix
   # or
   nix-env -iA nixpkgs.nixpkgs-fmt nixpkgs.statix
   ```

### Project Configuration

Complete example for a Nix project:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      # Format first
      - id: nix-fmt
        args: [--formatter=alejandra]

      # Then lint
      - id: nix-lint
        args: [--with-deadnix]

      # Validate builds
      - id: nix-build-check
        env:
          - NIX_BUILD_DRY_RUN=true

      # Flake validation
      - id: nix-flake-check

      # Platform-specific
      - id: nix-darwin-check     # macOS only
      - id: nix-home-manager-check
```

## Best Practices

1. **Order matters**: Run formatter before linter
2. **Use dry-run**: For faster CI/CD pipelines
3. **Pin versions**: Specify tool versions in your flake
4. **Incremental adoption**: Start with fmt, add linting later
5. **Platform awareness**: Some hooks are platform-specific

## Troubleshooting

### Performance Issues
- Use `NIX_BUILD_DRY_RUN=true` for build checks
- Limit file patterns to relevant directories
- Consider running expensive checks only on CI

### Tool Installation
All hooks attempt auto-installation, but you can pre-install:
```bash
# Using nix profile (newer)
nix profile install nixpkgs#{nixpkgs-fmt,alejandra,statix,deadnix}

# Using nix-env (traditional)
nix-env -iA nixpkgs.nixpkgs-fmt nixpkgs.alejandra nixpkgs.statix nixpkgs.deadnix
```

### Flake Issues
If flakes aren't recognized:
1. Check `nix --version` (should be 2.4+)
2. Verify experimental features are enabled
3. Try `nix flake check --help` to confirm

---
*For general hook documentation, see [index.md](index.md)*
