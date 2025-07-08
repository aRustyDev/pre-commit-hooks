# pre-commit-hooks

[![CI](https://github.com/aRustyDev/pre-commit-hooks/actions/workflows/ci.yml/badge.svg)](https://github.com/aRustyDev/pre-commit-hooks/actions/workflows/ci.yml)
[![Security](https://github.com/aRustyDev/pre-commit-hooks/actions/workflows/security.yml/badge.svg)](https://github.com/aRustyDev/pre-commit-hooks/actions/workflows/security.yml)
[![Coverage](https://github.com/aRustyDev/pre-commit-hooks/actions/workflows/coverage.yml/badge.svg)](https://github.com/aRustyDev/pre-commit-hooks/actions/workflows/coverage.yml)
[![GitHub release](https://img.shields.io/github/release/aRustyDev/pre-commit-hooks.svg)](https://github.com/aRustyDev/pre-commit-hooks/releases)
[![npm version](https://img.shields.io/npm/v/@arustydev/pre-commit-hooks.svg)](https://www.npmjs.com/package/@arustydev/pre-commit-hooks)
[![PyPI version](https://img.shields.io/pypi/v/arustydev-pre-commit-hooks.svg)](https://pypi.org/project/arustydev-pre-commit-hooks/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A collection of pre-commit hooks for various languages and tools to ensure code quality, security, and consistency.

## Features

- 🔍 **Multi-language support**: Hooks for Python, JavaScript, Go, Rust, Nix, and more
- 🛡️ **Security scanning**: Integration with security tools
- 📊 **Code quality**: Linting, formatting, and style checks
- 🚀 **CI/CD ready**: Works seamlessly with GitHub Actions
- 📦 **Multiple installation methods**: pre-commit, npm, pip, or direct download

## Installation

### Using pre-commit (Recommended)

Add this to your `.pre-commit-config.yaml`:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.1.0  # Use the latest release
    hooks:
      - id: shellcheck
      - id: shfmt
      # Add more hooks as needed
```

Then run:
```bash
pre-commit install
pre-commit run --all-files
```

### Using npm

```bash
npm install --save-dev @arustydev/pre-commit-hooks
```

### Using pip

```bash
pip install arustydev-pre-commit-hooks
```

### Direct Installation

```bash
curl -sSL https://github.com/aRustyDev/pre-commit-hooks/releases/latest/download/install.sh | bash
```

## Available Hooks

### Shell/Bash
- `shellcheck` - Shell script analysis
- `shfmt` - Shell script formatting

### Git/Commits
- `commitizen` - Conventional commit messages
- `commitlint` - Commit message linting
- `gitlint` - Git commit message linter

### Nix
- `nix-fmt` - Nix code formatter
- `nix-lint` - Nix linter
- `nix-build` - Nix build validation

### Web Development
- `eslint` - JavaScript linting
- `jshint` - JavaScript code quality
- `fixmyjs` - JavaScript auto-fixing
- `csslint` - CSS linting
- `scss-lint` - SCSS linting

### CI/CD
- `github-action-lint` - GitHub Actions workflow linting

### Configuration
- `yamlfmt` - YAML formatting

### Security
- `witness` - Supply chain security

## Usage Examples

### Basic Setup

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.1.0
    hooks:
      # Shell scripts
      - id: shellcheck
        args: [-x]
      - id: shfmt
        args: [-i, '2', -ci]

      # JavaScript
      - id: eslint
        files: \.js$

      # Commits
      - id: commitlint
        stages: [commit-msg]
```

### Advanced Configuration

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.1.0
    hooks:
      # Run on specific files
      - id: nix-fmt
        files: \.nix$

      # Custom arguments
      - id: shellcheck
        args: [--severity=warning]

      # Exclude patterns
      - id: eslint
        exclude: ^vendor/
```

## Development

### Prerequisites

- Python 3.6+
- Node.js 14+
- Bash 4+
- [pre-commit](https://pre-commit.com/)

### Setup

```bash
# Clone the repository
git clone https://github.com/aRustyDev/pre-commit-hooks.git
cd pre-commit-hooks

# Install dependencies
npm install
pip install -e .[dev]
pre-commit install

# Run tests
./tests/run_tests.sh
```

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Testing

Tests are written using [bats](https://github.com/bats-core/bats-core):

```bash
# Run all tests
./tests/run_tests.sh

# Run specific test
bats tests/commits/test_gitlint.bats

# Run with coverage
kcov coverage bats tests/
```

## Documentation

- [Hook Development Guide](docs/HOOK_DEVELOPMENT.md)
- [Release Process](docs/RELEASE_AUTOMATION.md)
- [Security Policy](SECURITY.md)

## Versioning

This project follows [Semantic Versioning](https://semver.org/). See [CHANGELOG.md](CHANGELOG.md) for release history.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Acknowledgments

- Pre-commit framework creators
- All contributors and hook authors
- Open source security tools integrated

## Support

- 🐛 [Report bugs](https://github.com/aRustyDev/pre-commit-hooks/issues)
- 💡 [Request features](https://github.com/aRustyDev/pre-commit-hooks/issues)
- 💬 [Discussions](https://github.com/aRustyDev/pre-commit-hooks/discussions)
- 📖 [Documentation](https://github.com/aRustyDev/pre-commit-hooks#readme)
