# Security Policy

## Supported Versions

We release patches for security vulnerabilities. Which versions are eligible for receiving such patches depends on the CVSS v3.0 Rating:

| Version | Supported          | Status              |
| ------- | ------------------ | ------------------- |
| latest  | :white_check_mark: | Active development  |
| < 1.0   | :x:                | Not supported       |

## Reporting a Vulnerability

We take the security of our pre-commit hooks seriously. If you believe you have found a security vulnerability, please report it to us as described below.

### How to Report

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report them via one of the following methods:

1. **GitHub Security Advisories**: [Create a security advisory](https://github.com/aRustyDev/pre-commit-hooks/security/advisories/new) (preferred)
2. **Email**: Send details to security@[maintainer-email].com

### What to Include

Please include the following information to help us triage your report quickly:

- Type of issue (e.g., command injection, path traversal, privilege escalation)
- Full paths of source file(s) related to the issue
- Location of the affected source code (tag/branch/commit or direct URL)
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Response Timeline

- **Initial Response**: Within 48 hours
- **Triage & Analysis**: Within 7 days
- **Resolution**: Depends on severity
  - Critical: Within 24-48 hours
  - High: Within 7 days
  - Medium: Within 30 days
  - Low: Within 90 days

## Security Considerations for Hook Development

When developing or contributing hooks, please follow these security guidelines:

### 1. Input Validation
- Always validate and sanitize user inputs
- Use proper quoting for shell variables: `"$var"` not `$var`
- Avoid using `eval` or similar dynamic execution

### 2. File Operations
- Use absolute paths where possible
- Validate file paths to prevent directory traversal
- Check file permissions before operations

### 3. External Commands
- Avoid constructing shell commands from user input
- Use command arrays instead of strings where possible
- Validate command existence before execution

### 4. Secrets Management
- Never hardcode secrets or credentials
- Use environment variables for sensitive data
- Ensure secrets are not logged or displayed

### 5. Dependencies
- Verify external tool versions and compatibility
- Use specific versions rather than "latest"
- Check tool signatures/checksums when downloading

## Security Tools

Our repository uses several security tools in CI/CD:

- **Trivy**: Vulnerability scanning
- **Gitleaks/TruffleHog**: Secret detection
- **ShellCheck**: Shell script analysis
- **CodeQL**: Static analysis
- **Dependabot**: Dependency updates

## Vulnerability Disclosure

After a security vulnerability is fixed:

1. We will publish a security advisory
2. Credit will be given to the reporter (unless anonymity is requested)
3. Details will be shared to help the community

## Security Best Practices for Users

When using these pre-commit hooks:

1. **Review hooks before use**: Examine the source code
2. **Use specific versions**: Pin to tagged releases
3. **Limit permissions**: Run with minimal required privileges
4. **Monitor updates**: Subscribe to security advisories
5. **Report issues**: Help us maintain security

## Contact

For any security-related questions that don't involve reporting a vulnerability, please open a [discussion](https://github.com/aRustyDev/pre-commit-hooks/discussions).

---

*This security policy is adapted from the [GitHub Security Policy template](https://docs.github.com/en/code-security/getting-started/adding-a-security-policy-to-your-repository)*
