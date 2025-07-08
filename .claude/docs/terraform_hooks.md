# Terraform Hooks

This document covers all Terraform-related pre-commit hooks provided by this repository.

## Available Hooks

### pluralith

**Purpose**: Generates infrastructure diagrams from Terraform code

**File Pattern**: `\.tf$`

**Status**: Tested ✅

**Configuration**:
- Environment: `PLURALITH_API_KEY`, `PLURALITH_PROJECT_ID`
- Arguments: `--apikey=<key>`, `--binpath=<path>`

**Example**:
```yaml
- id: pluralith
  args: [--apikey=$PLURALITH_API_KEY]
```

**Features**:
- Generates visual infrastructure diagrams
- Integrates with Pluralith cloud service
- Auto-installs CLI if not present
- Supports custom binary path

**Requirements**:
- Pluralith account (for API key)
- Valid Terraform configuration
- Internet connection for diagram generation

**Common Issues**:
- Missing API key: Sign up at https://pluralith.com
- Large infrastructures may take time to process

---

### tfupdate

**Purpose**: Updates Terraform version constraints

**File Pattern**: `\.tf$`

**Status**: UNTESTED ⚠️

**Configuration**:
- `GITHUB_TOKEN`: Required for API calls
- Arguments: `--provider=<name>`, `--module=<name>`

**Example**:
```yaml
- id: tfupdate
  args: [--provider=aws]
```

**Features**:
- Updates provider version constraints
- Updates module versions
- Updates Terraform core version
- Requires Go for installation

**Requirements**:
- `GITHUB_TOKEN` environment variable
- Go 1.16+ for tool installation
- Internet connection for version lookups

**Common Issues**:
- "GitHub PAT required" - Set `GITHUB_TOKEN` env var
- Rate limiting - Token helps avoid GitHub API limits

## Usage Patterns

### Complete Terraform Workflow

```yaml
repos:
  # Terraform-specific hooks
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      - id: pluralith
        # Generate diagrams on commit

  # Complement with terraform hooks
  - repo: https://github.com/antonbabenko/pre-commit-terraform
    rev: v1.77.1
    hooks:
      - id: terraform_fmt
      - id: terraform_validate
      - id: terraform_docs
```

### CI/CD Integration

For CI pipelines:
```yaml
- id: pluralith
  stages: [manual]  # Run only when needed
  args: [--ci-mode]
```

## Best Practices

1. **API Keys**: Store securely, use environment variables
2. **Version Updates**: Run tfupdate periodically, not on every commit
3. **Diagram Generation**: Consider running on push rather than commit
4. **Performance**: Large infrastructures may need timeout adjustments

## Troubleshooting

### Pluralith Issues

1. **Installation fails**:
   ```bash
   # Manual installation
   curl -L https://github.com/Pluralith/pluralith-cli/releases/latest/download/pluralith_cli_linux_amd64 -o pluralith
   chmod +x pluralith
   sudo mv pluralith /usr/local/bin/
   ```

2. **API connection errors**:
   - Verify API key is valid
   - Check network connectivity
   - Ensure project exists in Pluralith dashboard

### tfupdate Issues

1. **Go not installed**:
   ```bash
   # Install Go first
   brew install go
   # or
   nix-env -iA nixpkgs.go
   ```

2. **GitHub token issues**:
   ```bash
   # Create token at: https://github.com/settings/tokens
   export GITHUB_TOKEN=ghp_xxxxxxxxxxxx
   ```

## Future Enhancements

Based on TODO.md:
- `terraform test` runner hook
- Changelog automation for Terraform updates
- Integration with terraform-docs changes

---
*For general hook documentation, see [index.md](index.md)*
