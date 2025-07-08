# Commit Management Hooks

This document covers hooks related to commit message validation and standardization.

## Available Hooks

### commitlint

**Purpose**: Validates commit messages against conventional commit standards

**Status**: UNTESTED ⚠️

**Stage**: `commit-msg`

**Configuration**:
- Requires `commitlint` to be installed
- Uses `.commitlintrc` or `commitlint.config.js`

**Example**:
```yaml
- id: commitlint
  stages: [commit-msg]
```

**Features**:
- Enforces conventional commits
- Customizable rules
- Integrates with semantic-release
- Always runs (no file filtering)

---

### gitlint

**Purpose**: Checks git commit messages for style

**Status**: UNTESTED ⚠️

**Stage**: `commit-msg`

**Configuration**:
- Uses `.gitlint` configuration file
- Default args: `[--staged, --msg-filename]`

**Example**:
```yaml
- id: gitlint
```

**Features**:
- Python-based linting
- Extensive rule set
- User-defined rules
- Integration with CI

---

### gitlint-ci

**Purpose**: CI-specific version of gitlint

**Status**: UNTESTED ⚠️

**Stage**: `manual`

**Configuration**:
- `always_run: true`
- `pass_filenames: false`

**Example**:
```yaml
- id: gitlint-ci
  stages: [manual]
```

**Use Case**: Run in CI to check all commits in a PR

---

### commitizen

**Purpose**: Validates commit messages follow commitizen conventions

**Status**: UNTESTED ⚠️

**Stage**: `commit-msg`

**Configuration**:
- Default args: `[--allow-abort, --commit-msg-file]`
- Minimum pre-commit version: 1.4.3

**Example**:
```yaml
- id: commitizen
```

**Features**:
- Interactive commit creation
- Validates existing messages
- Configurable conventions
- Allows empty commits (aborts)

---

### commitizen-branch

**Purpose**: Checks all commits on current branch

**Status**: UNTESTED ⚠️

**Configuration**:
- Args: `[--rev-range, origin/HEAD..HEAD]`
- `always_run: true`
- `pass_filenames: false`

**Example**:
```yaml
- id: commitizen-branch
  stages: [push]
```

**Use Case**: Validate all commits before pushing

## Conventional Commits

Most of these hooks support the Conventional Commits specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Common Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Code style (formatting)
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes
- `build`: Build system changes

### Examples
```
feat(nix): add comprehensive Nix pre-commit hooks

fix: resolve dead link checker URL validation

docs: update README with installation instructions

chore(deps): bump pre-commit from 2.20.0 to 3.0.0
```

## Configuration Examples

### commitlint Setup

`.commitlintrc.json`:
```json
{
  "extends": ["@commitlint/config-conventional"],
  "rules": {
    "type-enum": [2, "always", [
      "feat", "fix", "docs", "style",
      "refactor", "test", "chore", "perf", "ci"
    ]],
    "scope-case": [2, "always", "lower-case"],
    "subject-case": [2, "never", ["sentence-case", "start-case", "pascal-case", "upper-case"]]
  }
}
```

### gitlint Setup

`.gitlint`:
```ini
[general]
ignore=body-is-missing,body-min-length

[title-match-regex]
regex=^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .+$

[title-max-length]
line-length=72

[body-max-line-length]
line-length=80
```

### commitizen Setup

`.cz.toml`:
```toml
[tool.commitizen]
name = "cz_conventional_commits"
version = "0.1.0"
tag_format = "v$version"
version_files = [
    "pyproject.toml:version"
]
```

## Recommended Workflow

### For Development Teams

Enforce consistent commit messages:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      # Check commit message format
      - id: commitizen
        stages: [commit-msg]

      # Validate all branch commits before push
      - id: commitizen-branch
        stages: [push]
```

### For Open Source Projects

More flexible approach:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      # Suggest but don't enforce
      - id: gitlint
        stages: [commit-msg]
        # Make it a warning, not error
        verbose: true
```

## Integration with Other Tools

### Semantic Release

Conventional commits enable automated releases:

```yaml
# .github/workflows/release.yml
- name: Semantic Release
  uses: semantic-release/semantic-release@v19
  # Will read conventional commits to determine version
```

### Changelog Generation

From TODO.md - planned automation:
- Auto-generate CHANGELOG from commits
- Group by type (feat, fix, etc.)
- Link to issues and PRs

## Troubleshooting

### Common Issues

1. **"commitlint not found"**:
   ```bash
   npm install -g @commitlint/cli @commitlint/config-conventional
   ```

2. **"gitlint not installed"**:
   ```bash
   pip install gitlint
   ```

3. **"commitizen not found"**:
   ```bash
   pip install commitizen
   ```

### Hook Conflicts

If using multiple commit hooks:
1. Choose one primary validator
2. Use others in CI only
3. Ensure consistent configuration

### Empty Commits

Some workflows use empty commits:
```bash
# Allow in commitizen
git commit --allow-empty -m "chore: trigger CI"
```

## Best Practices

1. **Start simple**: Begin with basic validation
2. **Document conventions**: Add to CONTRIBUTING.md
3. **Provide examples**: Show good commit messages
4. **Be consistent**: Use same rules everywhere
5. **Automate**: Use with semantic-release

## Future Enhancements

From TODO.md:
- Auto-update CHANGELOG.md using commit messages
- Integration with conventional changelog
- Commit message templates
- Auto-fix common issues

---
*For general hook documentation, see [index.md](index.md)*
