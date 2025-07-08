# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive CI/CD pipeline with GitHub Actions
- Security scanning workflow with multiple tools (Trivy, Gitleaks, CodeQL)
- Test framework using bats for shell script testing
- Code coverage reporting with kcov
- Automated dependency updates with Dependabot
- Hook development guide documentation
- Release automation workflow
- Multiple distribution channels (npm, PyPI, GitHub Releases)

### Changed
- Made all hook scripts executable
- Updated pre-commit configuration

### Fixed
- Shell script formatting issues
- Test compatibility across platforms

## [0.1.0] - 2024-08-21

### Added
- Initial collection of pre-commit hooks
- Basic documentation
- License file

[Unreleased]: https://github.com/aRustyDev/pre-commit-hooks/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/aRustyDev/pre-commit-hooks/releases/tag/v0.1.0
