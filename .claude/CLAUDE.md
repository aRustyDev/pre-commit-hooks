# CLAUDE.md - Pre-commit Hooks Project Context

## Project Overview
This repository provides a comprehensive collection of pre-commit hooks for various programming languages and tools. The hooks are designed to improve code quality, enforce standards, and automate repetitive tasks during the development workflow.

## Repository Structure
```
pre-commit-hooks/
├── .pre-commit-hooks.yaml    # Main hook definitions file
├── hooks/                    # Hook implementation scripts
│   ├── backup-nixos.sh      # System backup hooks
│   ├── ci/                  # CI/CD related hooks
│   ├── commits/             # Commit message hooks
│   ├── configs/             # Configuration file hooks
│   ├── docs/                # Documentation hooks
│   ├── nix/                 # Nix ecosystem hooks
│   ├── terraform/           # Terraform hooks
│   └── web/                 # Web technology hooks
├── tests/                   # Test fixtures and test scripts
├── docker/                  # Docker-related files
└── TODO.md                  # Project roadmap and tasks
```

## Key Technologies Supported
- **Nix**: Flakes, Darwin, Home-manager (6 hooks)
- **Terraform**: Formatting, validation, documentation
- **Rust/Cargo**: Formatting, linting, testing (7 hooks)
- **Web**: JavaScript, CSS, SCSS validation
- **Documentation**: Markdown link checking
- **Version Control**: Commit message validation

## Recent Additions (v0.3.0)
- Comprehensive Nix development hooks suite
- Rust/Cargo development tools
- Dead link checker for markdown
- Terraform diagram generation (Pluralith)

## Development Principles
1. **No sudo required**: All hooks must work without elevated privileges
2. **Auto-installation**: Tools should auto-install when possible
3. **Clear error messages**: Provide actionable feedback
4. **Cross-platform**: Support Linux, macOS, and WSL where applicable
5. **Configuration**: Support environment variables for customization

## Hook Categories
1. **Testing & Validation**: Ensure code correctness
2. **Formatting**: Maintain consistent code style
3. **Linting**: Catch potential issues early
4. **Documentation**: Keep docs up-to-date
5. **Security**: Prevent credential leaks
6. **Automation**: Reduce manual tasks

## Version Control Strategy
- Main branch: `main`
- Development branch: `dev`
- Feature branches: `feature/*`
- Semantic versioning: MAJOR.MINOR.PATCH
- Tagged releases with comprehensive notes

## Testing Requirements
- Each hook should have test fixtures
- Hooks marked "UNTESTED" need validation
- Platform-specific hooks should check compatibility
- Error cases must be handled gracefully

## Current Status
- **Implemented**: 40+ hooks across various languages
- **Tested**: Nix, Rust, and core hooks fully tested
- **Untested**: Several web and CI hooks need validation
- **In Progress**: See TODO.md for roadmap

## Common Patterns
1. **Script Structure**:
   ```bash
   #!/usr/bin/env bash
   # Check dependencies
   # Set PASS=true
   # Process files
   # Exit with proper code
   ```

2. **Error Handling**:
   - Check command availability
   - Provide installation instructions
   - Clear error messages
   - Non-zero exit on failure

3. **Configuration**:
   - Environment variables for options
   - Command-line arguments support
   - Sensible defaults

## Integration Points
- Pre-commit framework: https://pre-commit.com/
- GitHub Actions compatibility
- Docker support for isolated environments
- Package manager integrations (nix, cargo, npm, etc.)

## Contribution Guidelines
1. Follow existing patterns
2. Add tests for new hooks
3. Update .pre-commit-hooks.yaml
4. Document configuration options
5. Mark experimental hooks as "UNTESTED"

## Related Projects
- in-toto/witness: Supply chain attestations
- Various language-specific linters and formatters

## Maintenance Notes
- Regular updates for tool versions
- Monitor for deprecated hooks
- Community feedback integration
- Security vulnerability patches
