# Pre-commit Hooks Documentation Index

Welcome to the pre-commit hooks documentation. This directory contains detailed documentation for all hooks, organized by category.

## 📚 Documentation Structure

### Core Documentation
- [`project.md`](project.md) - Project overview, setup, and contribution guide
- [`../CLAUDE.md`](../CLAUDE.md) - AI context and project structure
- [`../HOOK_RULES.md`](../HOOK_RULES.md) - Hook development rules and standards

### Hook Documentation by Category

#### 🧪 Nix Ecosystem
- [`nix_hooks.md`](nix_hooks.md) - All Nix-related hooks
  - nix-flake-check
  - nix-build-check
  - nix-darwin-check
  - nix-home-manager-check
  - nix-fmt
  - nix-lint

#### 🏗️ Terraform
- [`terraform_hooks.md`](terraform_hooks.md) - Terraform development hooks
  - pluralith
  - tfupdate

#### 🦀 Rust/Cargo
- [`rust_hooks.md`](rust_hooks.md) - Rust development hooks
  - fmt
  - cargo-check
  - clippy
  - rustc
  - build-docs
  - generate-report
  - cargo-bench

#### 🌐 Web Development
- [`web_hooks.md`](web_hooks.md) - JavaScript, CSS, SCSS hooks
  - eslint
  - jshint
  - fixmyjs
  - csslint
  - scss-lint

#### 📝 Documentation
- [`docs_hooks.md`](docs_hooks.md) - Documentation maintenance hooks
  - dead-links

#### 💬 Commit Management
- [`commit_hooks.md`](commit_hooks.md) - Commit message validation
  - commitlint
  - gitlint
  - gitlint-ci
  - commitizen
  - commitizen-branch

#### 🔧 Configuration
- [`config_hooks.md`](config_hooks.md) - Configuration file hooks
  - yamlfmt

#### 🚀 CI/CD
- [`ci_hooks.md`](ci_hooks.md) - Continuous Integration hooks
  - actionlint
  - actionlint-docker
  - actionlint-system

#### 🔒 Security
- [`security_hooks.md`](security_hooks.md) - Security-related hooks
  - op-ggshield-img
  - bear-witness

#### 💾 System
- [`system_hooks.md`](system_hooks.md) - System-level hooks
  - backup-nixos-config
  - nixos-update-config

## 🔍 Finding Information

### By Task
- **Setting up a new language**: Check the specific language hook documentation
- **Adding a new hook**: Read [`../HOOK_RULES.md`](../HOOK_RULES.md) first
- **Troubleshooting**: See the specific hook's documentation and [`project.md`](project.md)
- **Contributing**: See [`project.md`](project.md) and [`../HOOK_RULES.md`](../HOOK_RULES.md)

### By Status
- **Fully Tested**: Nix, Rust, Documentation hooks
- **Untested**: Marked with "UNTESTED" in hook name
- **Not Implemented**: Marked with "NOT IMPLEMENTED"

### Quick Links
- [Installation Guide](project.md#installation)
- [Configuration Guide](project.md#configuration)
- [Troubleshooting](project.md#troubleshooting)
- [Contributing](project.md#contributing)

## 📋 Hook Status Matrix

| Category | Total | Tested | Untested | Not Implemented |
|----------|-------|---------|----------|-----------------|
| Nix | 7 | 7 | 0 | 0 |
| Rust | 7 | 7 | 0 | 0 |
| Web | 5 | 0 | 5 | 0 |
| Terraform | 2 | 1 | 1 | 0 |
| Documentation | 1 | 1 | 0 | 0 |
| Commits | 5 | 0 | 5 | 0 |
| CI/CD | 3 | 0 | 3 | 0 |
| Security | 2 | 0 | 1 | 1 |
| System | 2 | 1 | 0 | 1 |
| Config | 1 | 0 | 1 | 0 |

## 🚀 Getting Started

1. **New users**: Start with [`project.md`](project.md)
2. **Adding hooks to your project**: See language-specific documentation
3. **Developing new hooks**: Read [`../HOOK_RULES.md`](../HOOK_RULES.md)
4. **Contributing**: Check [`project.md#contributing`](project.md#contributing)

## 🔄 Documentation Updates

This documentation is maintained alongside the code. When adding or modifying hooks:
1. Update the relevant category documentation
2. Update this index if adding new categories
3. Ensure examples are tested and working
4. Mark untested hooks appropriately

---
*Last updated: v0.3.0*
