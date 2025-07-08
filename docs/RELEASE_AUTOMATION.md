# Release Automation Workflow

## Overview

Release automation streamlines the process of versioning, packaging, and distributing pre-commit hooks. This document details what a comprehensive release automation system would include.

## Components of Release Automation

### 1. Semantic Versioning

Automated version bumping based on commit messages:
- **feat:** commits trigger minor version bump (1.0.0 → 1.1.0)
- **fix:** commits trigger patch version bump (1.0.0 → 1.0.1)
- **BREAKING CHANGE:** triggers major version bump (1.0.0 → 2.0.0)

### 2. Changelog Generation

Automatically generate CHANGELOG.md from commit history:
- Groups changes by type (Features, Fixes, Breaking Changes)
- Includes commit links and PR references
- Shows contributor information

### 3. Release Workflow Components

```yaml
# .github/workflows/release.yml would include:

1. Trigger Conditions:
   - Manual workflow dispatch
   - Push to main with version tag
   - Scheduled releases (optional)

2. Pre-release Checks:
   - All tests pass
   - Security scans clean
   - Documentation up to date
   - No broken links

3. Version Management:
   - Calculate next version
   - Update version in files
   - Create git tag

4. Asset Generation:
   - Bundle hooks
   - Generate checksums
   - Create release notes

5. Publishing:
   - Create GitHub Release
   - Publish to package registries
   - Update documentation site

6. Post-release:
   - Announce release
   - Update issue templates
   - Trigger downstream updates
```

### 4. Distribution Channels

#### GitHub Releases
- Primary distribution method
- Includes release notes and assets
- Tagged versions for pre-commit

#### Package Registries
- **npm**: For JavaScript-based hooks
- **PyPI**: For Python integration
- **Homebrew**: For macOS users
- **AUR**: For Arch Linux users

#### Container Registry
- Docker images with all hooks pre-installed
- Multi-arch support (amd64, arm64)
- Minimal base images

### 5. Version File Management

Files automatically updated during release:
- `VERSION` - Single source of truth
- `.pre-commit-hooks.yaml` - Hook versions
- `package.json` - npm version
- `setup.py` - Python package version
- Documentation headers

### 6. Release Assets

Each release would include:
```
pre-commit-hooks-v1.2.3/
├── hooks/              # All hook scripts
├── tests/              # Test suite
├── docs/               # Documentation
├── CHANGELOG.md        # Release notes
├── checksums.txt       # SHA256 checksums
└── install.sh          # Installation script
```

### 7. Automated Release Notes

Generated from:
- Commit messages
- PR descriptions
- Issue references
- Breaking change notices

Format:
```markdown
## [1.2.3] - 2025-07-08

### 🚀 Features
- Add new terraform security scanner (#123)
- Support for YAML formatting hooks (#124)

### 🐛 Bug Fixes
- Fix shellcheck errors in nix hooks (#125)
- Correct eslint path detection (#126)

### 📚 Documentation
- Add hook development guide (#127)
- Update security policy (#128)

### ⚡ Performance
- Parallelize file processing (#129)

### 🔧 Maintenance
- Update dependencies (#130)
- Improve test coverage to 85% (#131)
```

### 8. Installation Methods

#### Direct pre-commit usage:
```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v1.2.3  # Automated tag
    hooks:
      - id: shellcheck
      - id: terraform-fmt
```

#### Script installation:
```bash
curl -sSL https://github.com/aRustyDev/pre-commit-hooks/releases/latest/download/install.sh | bash
```

#### Package manager:
```bash
# npm
npm install -g @arustydev/pre-commit-hooks

# pip
pip install arustydev-pre-commit-hooks

# brew
brew install arustydev/tap/pre-commit-hooks
```

### 9. Rollback Mechanism

- Keep previous versions available
- Document breaking changes clearly
- Provide migration guides
- Support version pinning

### 10. Quality Gates

Before release:
- ✅ All CI checks pass
- ✅ Test coverage > 80%
- ✅ No security vulnerabilities
- ✅ Documentation complete
- ✅ Changelog reviewed
- ✅ Version conflicts resolved

## Implementation Plan

### Phase 1: Basic Automation (Week 1)
1. Create release workflow
2. Implement version bumping
3. Generate basic changelog

### Phase 2: Distribution (Week 2)
1. Set up GitHub Releases
2. Create installation script
3. Document version pinning

### Phase 3: Package Publishing (Week 3)
1. Configure npm publishing
2. Set up PyPI distribution
3. Create Docker images

### Phase 4: Advanced Features (Week 4)
1. Automated dependency updates
2. Release metrics tracking
3. Downstream notification system

## Benefits

1. **Consistency**: Every release follows the same process
2. **Traceability**: Clear link between commits and releases
3. **Reliability**: Automated testing prevents broken releases
4. **Discoverability**: Easy for users to find and use specific versions
5. **Rollback**: Simple to revert to previous versions if needed

## Example Release Workflow

```yaml
name: Release

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Release version'
        required: true
        type: choice
        options:
          - patch
          - minor
          - major
          - prepatch
          - preminor
          - premajor

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Configure Git
        run: |
          git config user.name github-actions
          git config user.email github-actions@github.com

      - name: Bump version
        id: version
        run: |
          npm version ${{ github.event.inputs.version }} --no-git-tag-version
          echo "version=$(node -p "require('./package.json').version")" >> $GITHUB_OUTPUT

      - name: Generate changelog
        run: |
          npx conventional-changelog-cli -p angular -i CHANGELOG.md -s

      - name: Create release commit
        run: |
          git add .
          git commit -m "chore(release): v${{ steps.version.outputs.version }}"
          git tag -a "v${{ steps.version.outputs.version }}" -m "Release v${{ steps.version.outputs.version }}"

      - name: Push changes
        run: |
          git push origin main
          git push origin "v${{ steps.version.outputs.version }}"

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v${{ steps.version.outputs.version }}
          generate_release_notes: true
          files: |
            dist/*
            checksums.txt
```

This comprehensive release automation ensures consistent, reliable, and user-friendly distribution of pre-commit hooks.
