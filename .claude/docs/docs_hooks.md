# Documentation Hooks

This document covers hooks related to documentation maintenance and validation.

## Available Hooks

### dead-links

**Purpose**: Checks markdown files for broken relative links and URLs

**File Pattern**: `\.md$` (Markdown files)

**Status**: Tested ✅

**Features**:
- Validates relative file links
- Checks anchor links (#headings)
- Validates external URLs (with curl)
- Handles various markdown link formats
- Provides detailed error reporting

**Example**:
```yaml
- id: dead-links
```

**How it works**:
1. Extracts all links from markdown files using regex
2. For relative links: Verifies file exists
3. For anchor links: Checks heading exists in target file
4. For URLs: Performs HEAD request to verify accessibility

**Configuration**:
No environment variables currently, but the hook could be extended to support:
- Timeout for URL checks
- Whitelist for known-broken URLs
- Parallel URL checking

**Common Issues**:

1. **False positives on private URLs**:
   - Internal/private URLs may fail
   - Consider adding whitelist functionality

2. **Anchor link variations**:
   - Handles heading-to-anchor conversion
   - Spaces become hyphens, special chars removed

3. **Performance on many URLs**:
   - Each URL check is sequential
   - Large docs may be slow

**Error Examples**:
```
docs/guide.md: Link broken (File not found)
    | Link Path: /docs/missing.md

README.md: Link broken (Heading not found): 'configuration'
    | Link Path: SETUP.md

index.md: Link broken (URL not reachable): https://example.com/404
    | Target URL: https://example.com/404
```

## Best Practices

### Markdown Link Formats

The hook supports various formats:

```markdown
<!-- File links -->
[Link](./relative/path.md)
[Link](../parent/path.md)
[Link](/absolute/path.md)

<!-- Anchor links -->
[Link](#heading-in-same-file)
[Link](other.md#heading-in-other-file)

<!-- URLs -->
[Link](https://example.com)
[Link](http://example.com/page)
```

### Performance Optimization

For large documentation sets:

```yaml
- id: dead-links
  files: ^docs/.*\.md$  # Only check docs directory
```

Or split by type:

```yaml
# Check internal links frequently
- id: dead-links
  files: ^docs/.*\.md$
  name: Check internal links

# Check external URLs less frequently  
- id: dead-links
  files: ^README\.md$
  name: Check README links
  stages: [push]  # Only on push
```

### CI/CD Considerations

The hook makes network requests for URL validation:
- Ensure CI environment has internet access
- Consider caching URL check results
- May need proxy configuration in corporate environments

## Troubleshooting

### Network Issues

If URL checks fail in CI but work locally:
1. Check proxy settings
2. Verify firewall rules
3. Consider implementing retry logic

### Link Format Issues

Common problems:
- Spaces in filenames (use URL encoding)
- Case sensitivity on Linux vs macOS
- Absolute vs relative path confusion

### Performance

For faster checks:
1. Limit file scope with `files:` pattern
2. Skip URL checks in development
3. Run in parallel (future enhancement)

## Future Enhancements

Based on analysis and TODO.md:
- Parallel URL checking for performance
- Configurable timeout for URL requests
- Whitelist/blacklist for URLs
- Cache URL results with TTL
- Support for checking API documentation
- Integration with other doc validators

## Related Tools

This hook complements other documentation tools:
- `markdownlint`: Style and formatting
- `markdown-spellcheck`: Spelling errors
- `remark`: Markdown processing

Example complete documentation pipeline:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      - id: dead-links

  - repo: https://github.com/igorshubovych/markdownlint-cli
    rev: v0.33.0
    hooks:
      - id: markdownlint

  - repo: https://github.com/codespell-project/codespell
    rev: v2.2.2
    hooks:
      - id: codespell
        files: \.md$
```

## Testing

Test the hook manually:

```bash
# Test with sample files
./hooks/docs/dead-links.sh README.md

# Test with fixture
./hooks/docs/dead-links.sh tests/docs/fixtures/broken-links.md
```

Create test fixtures:

```markdown
<!-- tests/docs/fixtures/broken-links.md -->
# Test Document

[Working link](./existing-file.md)
[Broken link](./missing-file.md)
[Bad anchor](./existing-file.md#missing-heading)
[Dead URL](https://this-domain-does-not-exist-12345.com)
```

---
*For general hook documentation, see [index.md](index.md)*
