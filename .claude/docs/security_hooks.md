# Security Hooks

This document covers security-related pre-commit hooks for preventing credential leaks and ensuring supply chain integrity.

## Available Hooks

### op-ggshield-img

**Purpose**: Scans for secrets and credentials using GitGuardian via 1Password

**Status**: Tested ✅

**Type**: Docker image

**Configuration**:
- Requires 1Password CLI (`op`)
- Requires GitGuardian credentials stored in 1Password
- Uses Docker for isolation

**Example**:
```yaml
- id: op-ggshield-img
```

**Features**:
- Detects API keys, passwords, tokens
- Integrates with 1Password for secure credential management
- Runs in Docker container for isolation
- Scans all text files by default

**How it works**:
1. Pulls ggshield Docker image
2. Uses 1Password CLI to retrieve GitGuardian credentials
3. Scans files for potential secrets
4. Blocks commit if secrets detected

**Requirements**:
- Docker installed and running
- 1Password CLI configured
- GitGuardian API credentials in 1Password

---

### bear-witness

**Purpose**: Generate supply chain attestations using in-toto witness

**Status**: NOT IMPLEMENTED ⚠️

**Stages**: `[pre-commit, post-commit, post-checkout, pre-push]`

**Planned Features**:
- Software supply chain attestations
- Cryptographic signatures on commits
- Build provenance tracking
- SLSA compliance support

**Example**:
```yaml
- id: bear-witness
  stages: [pre-commit, post-commit]
```

**Future Implementation**:
Based on TODO.md, this will:
- Generate attestations for commits
- Track software supply chain steps
- Integrate with in-toto framework
- Support witness configuration

## Security Best Practices

### Secret Scanning Setup

1. **Basic secret scanning** (without 1Password):
   ```yaml
   # Use alternative secret scanners
   - repo: https://github.com/Yelp/detect-secrets
     rev: v1.4.0
     hooks:
       - id: detect-secrets
   ```

2. **With ggshield** (direct):
   ```yaml
   - repo: https://github.com/gitguardian/ggshield
     rev: v1.25.0
     hooks:
       - id: ggshield
         language: python
         stages: [commit]
   ```

### Defense in Depth

Layer multiple security checks:

```yaml
repos:
  # Credential scanning
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      - id: op-ggshield-img

  # File permission checks
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: detect-private-key
      - id: check-added-large-files

  # Supply chain (when implemented)
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      - id: bear-witness
        stages: [pre-push]
```

## Configuration

### GitGuardian Setup

1. **Get API key**: https://dashboard.gitguardian.com/
2. **Store in 1Password**:
   ```bash
   op item create --category=apikey \
     --title="GitGuardian API" \
     --vault="Development" \
     apikey="your-api-key"
   ```
3. **Configure ggshield**:
   ```bash
   ggshield config set instance https://api.gitguardian.com
   ```

### Docker Requirements

For `op-ggshield-img`:
- Docker Desktop or Docker Engine
- Sufficient disk space for images
- Network access to Docker Hub

## Common Secret Patterns

The hooks detect various secret types:

### API Keys
- AWS: `AKIA[0-9A-Z]{16}`
- Google: `AIza[0-9A-Za-z\\-_]{35}`
- GitHub: `ghp_[0-9a-zA-Z]{36}`

### Passwords
- Hardcoded passwords in code
- Database connection strings
- Basic auth credentials

### Tokens
- JWT tokens
- OAuth tokens
- Session tokens

### Private Keys
- SSH private keys
- SSL/TLS private keys
- GPG private keys

## Troubleshooting

### op-ggshield-img Issues

1. **"Docker not running"**:
   ```bash
   # Start Docker
   docker info  # Check if running
   ```

2. **"1Password CLI not configured"**:
   ```bash
   # Sign in to 1Password
   op signin
   ```

3. **"Cannot pull Docker image"**:
   - Check network connectivity
   - Verify Docker Hub access
   - Check disk space

### False Positives

Handle false positives:

1. **Add to .gitguardian.yml**:
   ```yaml
   paths-ignore:
     - "tests/fixtures/*"
     - "docs/examples/*"
   ```

2. **Inline ignores**:
   ```python
   # ggignore
   api_key = "example-key-for-docs"
   ```

## Supply Chain Security (Future)

### in-toto/witness Integration

When implemented, will provide:

1. **Attestation generation**:
   - Link metadata for each step
   - Cryptographic signatures
   - Material/product tracking

2. **Policy enforcement**:
   - Define allowed operations
   - Verify supply chain steps
   - Prevent unauthorized changes

3. **Integration points**:
   - Pre-commit: Record materials
   - Post-commit: Generate attestation
   - Pre-push: Verify policy

### SLSA Compliance

Future support for SLSA levels:
- Level 1: Basic attestation
- Level 2: Hosted build platform
- Level 3: Hardened builds
- Level 4: Two-party review

## Best Practices

1. **Never commit secrets**: Even in private repos
2. **Rotate compromised credentials**: Immediately
3. **Use secret management**: Not hardcoded values
4. **Regular scans**: Not just pre-commit
5. **Defense in depth**: Multiple security layers

## Future Enhancements

From TODO.md:
- Complete witness implementation
- Add cosign support
- SBOM generation for Nix
- Integration with other attestation frameworks

## Related Security Tools

Complement these hooks with:
- `talisman`: Pre-push secret scanning
- `trufflehog`: Deep secret scanning
- `gitleaks`: Fast secret detection
- `semgrep`: Static analysis security

---
*For general hook documentation, see [index.md](index.md)*
