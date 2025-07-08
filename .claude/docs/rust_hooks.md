# Rust/Cargo Hooks

This document covers all Rust and Cargo-related pre-commit hooks provided by this repository.

## Available Hooks

### fmt

**Purpose**: Format Rust code using `cargo fmt`

**File Pattern**: Rust files (`types: [rust]`)

**Status**: Tested ✅

**Example**:
```yaml
- id: fmt
```

**Features**:
- Uses project's rustfmt.toml if present
- Ensures consistent code style
- Fast execution
- Modifies files in place

**Common Issues**:
- Requires `rustfmt` component: `rustup component add rustfmt`

---

### cargo-check

**Purpose**: Check Rust code for errors without building

**File Pattern**: Rust files (`types: [rust]`)

**Status**: Tested ✅

**Configuration**:
- `pass_filenames: false` - Checks entire project

**Example**:
```yaml
- id: cargo-check
```

**Features**:
- Fast error checking
- No compilation artifacts
- Catches type errors and basic issues
- Runs on entire project

**Common Issues**:
- May fail if dependencies aren't fetched
- Run `cargo fetch` first if needed

---

### clippy

**Purpose**: Lint Rust code for common mistakes and style issues

**File Pattern**: Rust files (`types: [rust]`)

**Status**: Tested ✅

**Configuration**:
- Default args: `["--", "-D", "warnings"]`
- `pass_filenames: false` - Lints entire project

**Example**:
```yaml
- id: clippy
  args: ["--", "-D", "warnings", "-W", "clippy::unwrap_used"]
```

**Features**:
- Comprehensive linting
- Configurable warning levels
- Suggests idiomatic code
- Catches potential bugs

**Common Issues**:
- Requires `clippy` component: `rustup component add clippy`
- May be strict with `-D warnings`

---

### rustc

**Purpose**: Run the Rust compiler

**File Pattern**: Rust files (`types: [rust]`)

**Status**: Tested ✅

**Configuration**:
- `always_run: true`
- `pass_filenames: false`

**Example**:
```yaml
- id: rustc
```

**Features**:
- Full compilation check
- Verifies successful build
- Always runs regardless of changed files

**Note**: This is slower than `cargo-check` as it produces artifacts

---

### build-docs

**Purpose**: Build Rust documentation

**File Pattern**: Rust files (`types: [rust]`)

**Status**: Tested ✅

**Configuration**:
- `always_run: true`
- `pass_filenames: false`

**Example**:
```yaml
- id: build-docs
```

**Features**:
- Generates HTML documentation
- Checks doc comments for errors
- Verifies doc examples
- Always runs to ensure docs stay updated

**Common Issues**:
- Doc tests may fail if examples are incorrect
- Private items need `--document-private-items`

---

### generate-report

**Purpose**: Check for future Rust incompatibilities

**File Pattern**: Rust files (`types: [rust]`)

**Status**: Tested ✅

**Configuration**:
- `pass_filenames: false`

**Example**:
```yaml
- id: generate-report
```

**Features**:
- Reports future compatibility issues
- Helps prepare for Rust edition updates
- Identifies deprecated patterns

**Note**: Requires a previous build with future-incompat warnings

---

### cargo-bench

**Purpose**: Run Rust benchmarks

**File Pattern**: Rust files (`types: [rust]`)

**Status**: Tested ✅

**Configuration**:
- `pass_filenames: false`

**Example**:
```yaml
- id: cargo-bench
  stages: [manual]  # Don't run on every commit
```

**Features**:
- Runs performance benchmarks
- Compares against baseline
- Helps catch performance regressions

**Best Practice**: Run manually or in CI, not on every commit

## Recommended Configuration

### Development Setup

For active Rust development:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      # Fast checks on every commit
      - id: fmt
      - id: cargo-check

      # Thorough checks
      - id: clippy
        args: ["--", "-D", "warnings"]

      # Documentation
      - id: build-docs
        stages: [push]  # Only on push

      # Manual runs
      - id: cargo-bench
        stages: [manual]
```

### CI Configuration

For continuous integration:

```yaml
repos:
  - repo: https://github.com/aRustyDev/pre-commit-hooks
    rev: v0.3.0
    hooks:
      - id: fmt
        args: ["--", "--check"]  # Check only
      - id: clippy
        args: ["--", "-D", "warnings", "-D", "clippy::all"]
      - id: rustc
      - id: build-docs
      - id: generate-report
```

## Best Practices

1. **Order of execution**:
   - fmt → cargo-check → clippy → rustc
   - Format first, then validate

2. **Performance optimization**:
   - Use `cargo-check` for quick feedback
   - Save `rustc` and `cargo-bench` for CI

3. **Clippy configuration**:
   - Start with default warnings
   - Gradually increase strictness
   - Use `clippy.toml` for project-wide rules

4. **Documentation**:
   - Run `build-docs` before releases
   - Ensure all public items are documented

## Troubleshooting

### Missing Components

Install required Rust components:
```bash
rustup component add rustfmt clippy
```

### Performance Issues

1. **Slow checks**: Use `cargo-check` instead of `rustc`
2. **Benchmark overhead**: Move to manual stage
3. **Large projects**: Consider workspace-specific checks

### Configuration

Create `rustfmt.toml` for formatting rules:
```toml
edition = "2021"
max_width = 100
use_small_heuristics = "Max"
```

Create `clippy.toml` for linting rules:
```toml
disallowed-methods = [
    { path = "std::env::set_var", reason = "Use a crate that handles concurrency" },
]
```

## Future Enhancements

From TODO.md:
- Sort `mod.rs` file contents
- Check code documentation coverage
- Integration with cargo-audit for security

---
*For general hook documentation, see [index.md](index.md)*
