# Branch Protection Configuration

This document outlines the recommended branch protection rules for the `main` branch.

## Setting Up Branch Protection

1. Navigate to **Settings** → **Branches** in your GitHub repository
2. Click **Add rule** under "Branch protection rules"
3. Enter `main` as the branch name pattern

## Recommended Settings

### ✅ Required Status Checks

Enable "Require status checks to pass before merging" with these checks:

- [ ] **CI / Lint Shell Scripts** - Ensures code quality
- [ ] **CI / Pre-commit Hooks** - Validates all hooks
- [ ] **CI / Test Hooks** - Runs all tests
- [ ] **CI / Validate Nix Files** - Checks Nix syntax
- [ ] **CI / CI Summary** - Overall CI status
- [ ] **Security / Trivy Security Scan** - Vulnerability check
- [ ] **Security / Secret Detection** - Prevents secret leaks
- [ ] **Security / ShellCheck Security Analysis** - Security patterns

Select:
- [x] **Require branches to be up to date before merging**

### ✅ Required Reviews

Enable "Require a pull request before merging" with:

- [ ] **Require approvals**: 1 (minimum)
- [ ] **Dismiss stale pull request approvals when new commits are pushed**
- [ ] **Require review from CODEOWNERS** (if CODEOWNERS file exists)
- [ ] **Require approval of the most recent reviewable push**

### ✅ Additional Protection

- [ ] **Require signed commits** - Ensures commit authenticity
- [ ] **Require linear history** - Maintains clean git history
- [ ] **Include administrators** - Apply rules to admins too
- [ ] **Allow force pushes** - ❌ DISABLED (never allow)
- [ ] **Allow deletions** - ❌ DISABLED (protect main branch)

### ✅ Merge Restrictions

- [ ] **Restrict who can push to matching branches**
  - Add specific users/teams if needed
  - Otherwise, leave unrestricted for open source

## Enforcement

- [ ] **Do not allow bypassing the above settings**

## Additional Recommendations

### For Open Source Projects

1. Enable **Require contributors to sign off on commits** for DCO compliance
2. Consider **Require conversation resolution before merging**

### For Private/Corporate Projects

1. Enable **Restrict who can push to matching branches**
2. Add specific teams/users with merge permissions
3. Consider requiring 2+ reviews for critical changes

## Automation

To apply these settings programmatically:

```bash
# Using GitHub CLI
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["CI / CI Summary","Security / Security Summary"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}' \
  --field restrictions=null \
  --field allow_force_pushes=false \
  --field allow_deletions=false
```

## Monitoring

Regular checks to ensure protection is active:

```bash
# Check protection status
gh api repos/:owner/:repo/branches/main/protection
```

## Emergency Procedures

If branch protection needs temporary modification:

1. Document the reason in an issue
2. Make the minimal necessary change
3. Re-enable full protection immediately after
4. Review the emergency change in the next team meeting

---

*Note: These settings ensure code quality and security while maintaining development velocity.*
