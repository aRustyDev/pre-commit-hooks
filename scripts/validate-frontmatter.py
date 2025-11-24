#!/usr/bin/env python3
"""Validate YAML frontmatter in markdown documents.

This validator supports:
- Configuration file for flexible scanning behavior
- UUID cache for fast repeated validation
- Two-phase discovery for accurate single-file validation

Configuration Schema (.frontmatter-config.json):
    {
      "version": "1.0",
      "scan": {
        "directories": [".ai", "docs"],
        "exclude_patterns": ["**/templates/**", "**/artifacts/**"]
      },
      "validation": {
        "required_fields": ["id", "title", "status", "date", "author"],
        "validate_cross_references": true,
        "title_must_match_h1": true
      },
      "cache": {
        "enabled": false,
        "path": "./data/.uuid-cache.json",
        "ttl_seconds": null
      }
    }

Cache Schema (./data/.uuid-cache.json):
    {
      "version": "1.0",
      "created": "2025-11-23T10:30:00Z",
      "timestamp": 1700000000,
      "config_hash": "a1b2c3d4e5f6",
      "file_count": 40,
      "file_mtimes": {
        ".ai/INDEX.md": 1699999999
      },
      "uuids": {
        "15754957-34F7-418C-8E2A-319175C225C3": ".ai/INDEX.md"
      }
    }
"""

import argparse
import hashlib
import json
import re
import sys
import time
from copy import deepcopy
from datetime import datetime
from pathlib import Path


class FrontmatterValidator:
    """Validates markdown frontmatter against project standards.

    Supports configuration-based scanning, UUID caching, and two-phase
    discovery for accurate single-file validation with cross-reference checking.
    """

    # Validation patterns
    REQUIRED_FIELDS = {"id", "title", "status", "date", "author"}
    UUID_PATTERN = re.compile(
        r"^[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}$"
    )
    DATE_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}$")
    FRONTMATTER_PATTERN = re.compile(r"^---\n(.*?)\n---", re.DOTALL | re.MULTILINE)

    # Schema versions
    CONFIG_VERSION = "1.0"
    CACHE_VERSION = "1.0"

    def __init__(self, config_path=".ai/.frontmatter-config.json", cache_path=None):
        """Initialize validator with optional configuration file.

        Args:
            config_path (str): Path to configuration file (default: .ai/.frontmatter-config.json)
            cache_path (str, optional): Path to UUID cache file (overrides config setting)
        """
        self.errors = []
        self.warnings = []
        self.all_uuids = {}  # UUID -> file path
        self._uuid_map_ready = False  # Track if UUID discovery has run

        # Load configuration (with defaults if file doesn't exist)
        self.config = self._load_config(config_path)

        # Override cache path if specified via CLI
        if cache_path is not None:
            self.config["cache"]["path"] = cache_path

    @staticmethod
    def get_default_config():
        """Return default configuration schema.

        This configuration is used when no .frontmatter-config.json exists.
        Provides sensible defaults that work for most projects.

        Returns:
            dict: Default configuration matching CONFIG_SCHEMA
        """
        return {
            "version": FrontmatterValidator.CONFIG_VERSION,
            "scan": {
                "directories": [".ai", "docs"],
                "exclude_patterns": ["**/templates/**", "**/artifacts/**"],
            },
            "validation": {
                "required_fields": ["id", "title", "status", "date", "author"],
                "validate_cross_references": True,
                "title_must_match_h1": True,
            },
            "cache": {
                "enabled": False,  # Conservative default
                "path": "./data/.uuid-cache.json",
                "ttl_seconds": None,  # No TTL by default
            },
        }

    @staticmethod
    def get_cache_schema_template():
        """Return cache file schema template.

        This defines the structure of ./data/.uuid-cache.json
        Used for documentation and validation.

        Cache Invalidation Triggers:
        - config_hash changes (config file modified)
        - file_mtimes mismatch (file modified)
        - file_count mismatch (file added/removed)
        - version mismatch (schema changed)
        - ttl_seconds exceeded (if configured)

        Returns:
            dict: Cache schema template
        """
        return {
            "version": FrontmatterValidator.CACHE_VERSION,
            "created": "ISO 8601 timestamp",
            "timestamp": "Unix timestamp (float)",
            "config_hash": "MD5 hash of scan + validation config",
            "file_count": "Number of markdown files tracked",
            "file_mtimes": {"file_path": "Unix mtime (float)"},
            "uuids": {"UUID": "file_path"},
        }

    @staticmethod
    def validate_config_schema(config):
        """Validate configuration against schema.

        Args:
            config (dict): Configuration to validate

        Returns:
            tuple: (is_valid, error_message)
        """
        # Check version
        if "version" not in config:
            return False, "Missing 'version' field"

        if config["version"] != FrontmatterValidator.CONFIG_VERSION:
            return False, f"Unsupported version: {config['version']}"

        # Check required top-level keys
        required_keys = {"version", "scan", "validation", "cache"}
        if not required_keys.issubset(config.keys()):
            missing = required_keys - config.keys()
            return False, f"Missing required keys: {missing}"

        # Validate scan section
        if "directories" not in config["scan"]:
            return False, "scan.directories is required"

        if not isinstance(config["scan"]["directories"], list):
            return False, "scan.directories must be a list"

        # Validate cache section
        if "enabled" not in config["cache"]:
            return False, "cache.enabled is required"

        if not isinstance(config["cache"]["enabled"], bool):
            return False, "cache.enabled must be boolean"

        return True, None

    @staticmethod
    def validate_cache_schema(cache):
        """Validate cache file against schema.

        Args:
            cache (dict): Cache data to validate

        Returns:
            tuple: (is_valid, error_message)
        """
        # Check version
        if cache.get("version") != FrontmatterValidator.CACHE_VERSION:
            return False, f"Unsupported cache version: {cache.get('version')}"

        # Check required fields
        required = {
            "version",
            "timestamp",
            "config_hash",
            "file_count",
            "file_mtimes",
            "uuids",
        }
        if not required.issubset(cache.keys()):
            missing = required - cache.keys()
            return False, f"Missing required cache fields: {missing}"

        # Validate types
        if not isinstance(cache["file_mtimes"], dict):
            return False, "file_mtimes must be a dict"

        if not isinstance(cache["uuids"], dict):
            return False, "uuids must be a dict"

        return True, None

    def _load_config(self, config_path):
        """Load user configuration or return defaults.

        Args:
            config_path (str): Path to configuration file

        Returns:
            dict: Configuration (user config merged with defaults)
        """
        path = Path(config_path)

        if path.exists():
            try:
                user_config = json.loads(path.read_text())

                # Merge with defaults first (allows partial configs)
                merged = self._merge_with_defaults(user_config)

                # Validate the merged config (should always be valid)
                is_valid, error = self.validate_config_schema(merged)
                if not is_valid:
                    print(f"Warning: Config validation failed after merge: {error}")
                    print("Using default configuration")
                    return self.get_default_config()

                return merged
            except json.JSONDecodeError as e:
                print(f"Warning: Failed to parse config at {path}: {e}")
                print("Using default configuration")
                return self.get_default_config()
        else:
            # No config file - use defaults
            return self.get_default_config()

    def _merge_with_defaults(self, user_config):
        """Deep merge user config with defaults.

        Args:
            user_config (dict): User-provided configuration

        Returns:
            dict: Merged configuration
        """
        defaults = self.get_default_config()

        def merge(base, override):
            """Recursively merge override into base."""
            result = deepcopy(base)
            for key, value in override.items():
                if (
                    key in result
                    and isinstance(result[key], dict)
                    and isinstance(value, dict)
                ):
                    result[key] = merge(result[key], value)
                else:
                    result[key] = value
            return result

        return merge(defaults, user_config)

    def prepare_uuid_map(self):
        """Build complete UUID map using cache if available.

        This is the main entry point for UUID discovery. It either loads
        UUIDs from cache (if valid) or performs a full scan of all markdown
        files based on configuration.

        After calling this method, self.all_uuids contains a complete mapping
        of all UUIDs in the knowledge base, enabling accurate cross-reference
        validation even when validating a single file.
        """
        if self._uuid_map_ready:
            return  # Already prepared

        # Try cache first (if enabled)
        if self.config["cache"]["enabled"]:
            if self._load_uuid_cache():
                self._uuid_map_ready = True
                return  # Cache hit!

        # Cache miss or disabled - do full discovery
        self._discover_all_uuids()

        # Save cache for next time (if enabled)
        if self.config["cache"]["enabled"]:
            self._save_uuid_cache()

        self._uuid_map_ready = True

    def _discover_all_uuids(self):
        """Scan all markdown files to build complete UUID map.

        Scans directories specified in config and builds a mapping of
        UUID -> file path for all markdown files (excluding patterns
        from config).
        """
        for base_dir in self.config["scan"]["directories"]:
            dir_path = Path(base_dir)
            if not dir_path.exists():
                continue

            for md_file in dir_path.rglob("*.md"):
                # Apply exclusions
                if self._should_exclude(md_file):
                    continue

                # Quick extraction - just grab the UUID
                uuid = self._extract_uuid_only(md_file)
                if uuid and self.UUID_PATTERN.match(uuid):
                    self.all_uuids[uuid] = md_file

    def _extract_uuid_only(self, file_path):
        """Quickly extract just the UUID from frontmatter.

        This is optimized for speed - only reads the first ~30 lines
        and does minimal parsing to extract the UUID.

        Args:
            file_path (Path): Path to markdown file

        Returns:
            str or None: UUID if found, None otherwise
        """
        try:
            with open(file_path, encoding="utf-8") as f:
                # Read only first ~30 lines (frontmatter should be at top)
                content = ""
                for i, line in enumerate(f):
                    content += line
                    if i > 30:
                        break

            # Quick check - does it start with frontmatter?
            if not content.strip().startswith("---"):
                return None

            match = self.FRONTMATTER_PATTERN.match(content)
            if not match:
                return None

            # Simple extraction - look for "id: UUID"
            for line in match.group(1).split("\n"):
                line = line.strip()
                if line.startswith("id:"):
                    uuid = line.split(":", 1)[1].strip()
                    return uuid

            return None
        except Exception:
            # Ignore files we can't read
            return None

    def _should_exclude(self, file_path):
        """Check if file matches exclusion patterns.

        Args:
            file_path (Path): Path to check

        Returns:
            bool: True if file should be excluded
        """
        file_str = str(file_path)
        for pattern in self.config["scan"].get("exclude_patterns", []):
            if Path(file_str).match(pattern):
                return True
        return False

    def _count_markdown_files(self):
        """Count markdown files in scan directories.

        Returns:
            int: Number of markdown files (excluding patterns)
        """
        count = 0
        for base_dir in self.config["scan"]["directories"]:
            dir_path = Path(base_dir)
            if not dir_path.exists():
                continue
            for md_file in dir_path.rglob("*.md"):
                if not self._should_exclude(md_file):
                    count += 1
        return count

    def _hash_config(self):
        """Generate hash of current config for cache invalidation.

        Only hashes the parts that affect scanning and validation,
        not the cache settings themselves.

        Returns:
            str: MD5 hash (12 chars)
        """
        # Hash relevant config parts (scan and validation settings)
        config_str = json.dumps(
            {"scan": self.config["scan"], "validation": self.config["validation"]},
            sort_keys=True,
        )

        return hashlib.md5(config_str.encode()).hexdigest()[:12]

    def _load_uuid_cache(self):
        """Load UUID cache if valid.

        Returns:
            bool: True if cache loaded successfully, False otherwise
        """
        cache_path = Path(self.config["cache"]["path"])

        if not cache_path.exists():
            return False

        try:
            cache = json.loads(cache_path.read_text())

            # Validate cache schema
            is_valid, error = self.validate_cache_schema(cache)
            if not is_valid:
                return False

            # Check if cache is still valid
            if not self._is_cache_valid(cache):
                return False

            # Load UUIDs from cache
            self.all_uuids = {
                uuid: Path(file_path) for uuid, file_path in cache["uuids"].items()
            }

            return True

        except (json.JSONDecodeError, KeyError, TypeError):
            # Cache corrupted, ignore it
            return False

    def _is_cache_valid(self, cache):
        """Check if cache is still fresh.

        Args:
            cache (dict): Cache data to validate

        Returns:
            bool: True if cache is valid, False if stale
        """
        # Check version
        if cache.get("version") != self.CACHE_VERSION:
            return False

        # Check config hash
        current_hash = self._hash_config()
        if cache.get("config_hash") != current_hash:
            return False

        # Check file count
        cached_count = cache.get("file_count", 0)
        current_count = self._count_markdown_files()
        if current_count != cached_count:
            return False

        # Check file mtimes
        for file_path, cached_mtime in cache.get("file_mtimes", {}).items():
            path = Path(file_path)

            # File deleted
            if not path.exists():
                return False

            # File modified
            try:
                if path.stat().st_mtime > cached_mtime:
                    return False
            except OSError:
                # Can't stat file, consider cache invalid
                return False

        # Check TTL (if configured)
        ttl = self.config["cache"].get("ttl_seconds")
        if ttl is not None:
            age = time.time() - cache.get("timestamp", 0)
            if age > ttl:
                return False

        return True

    def _save_uuid_cache(self):
        """Save current UUID map to cache.

        Saves cache even if errors occur (won't fail validation).
        """
        cache_path = Path(self.config["cache"]["path"])

        # Build cache structure
        cache = {
            "version": self.CACHE_VERSION,
            "created": datetime.now().isoformat(),
            "timestamp": time.time(),
            "config_hash": self._hash_config(),
            "file_count": len(self.all_uuids),
            "file_mtimes": {},
            "uuids": {},
        }

        # Collect file mtimes and UUIDs
        for uuid, file_path in self.all_uuids.items():
            file_str = str(file_path)
            cache["uuids"][uuid] = file_str

            if file_path.exists():
                try:
                    cache["file_mtimes"][file_str] = file_path.stat().st_mtime
                except OSError:
                    # Can't stat file, skip mtime
                    pass

        # Ensure directory exists
        try:
            cache_path.parent.mkdir(parents=True, exist_ok=True)

            # Write cache
            cache_path.write_text(json.dumps(cache, indent=2))
        except (OSError, IOError):
            # Don't fail validation if cache save fails
            pass

    def validate_file(self, file_path: Path) -> bool:
        """Validate a single markdown file."""
        with open(file_path, encoding="utf-8") as f:
            content = f.read()

        # Check if frontmatter exists
        if not content.strip().startswith("---"):
            self.errors.append(f"{file_path}: No frontmatter found")
            return False

        # Extract frontmatter
        match = self.FRONTMATTER_PATTERN.match(content)
        if not match:
            self.errors.append(f"{file_path}: Invalid frontmatter format")
            return False

        frontmatter = self._parse_frontmatter(match.group(1))

        # Validate required fields
        missing = self.REQUIRED_FIELDS - frontmatter.keys()
        if missing:
            self.errors.append(
                f"{file_path}: Missing required fields: {', '.join(missing)}"
            )
            return False

        # Validate UUID format
        if not self.UUID_PATTERN.match(frontmatter["id"]):
            self.errors.append(f"{file_path}: Invalid UUID format: {frontmatter['id']}")
            return False

        # Check for duplicate UUIDs
        if frontmatter["id"] in self.all_uuids:
            existing_path = self.all_uuids[frontmatter["id"]]
            # Only error if UUID exists in a DIFFERENT file
            # (If UUID map was prepared, this file's UUID is already in the map)
            # Normalize paths for comparison (resolve to absolute paths)
            try:
                if existing_path.resolve() != file_path.resolve():
                    self.errors.append(
                        f"{file_path}: Duplicate UUID {frontmatter['id']} "
                        f"(also in {existing_path})"
                    )
                    return False
            except (AttributeError, OSError):
                # Path comparison failed, assume different files
                if str(existing_path) != str(file_path):
                    self.errors.append(
                        f"{file_path}: Duplicate UUID {frontmatter['id']} "
                        f"(also in {existing_path})"
                    )
                    return False
        else:
            # Add to UUID map (if not already there from preparation)
            self.all_uuids[frontmatter["id"]] = file_path

        # Validate date format
        if not self.DATE_PATTERN.match(frontmatter["date"]):
            self.errors.append(
                f"{file_path}: Invalid date format: {frontmatter['date']}"
            )
            return False

        # Check title matches H1
        title_match = re.search(r"^#\s+(.+)$", content, re.MULTILINE)
        if title_match and title_match.group(1) != frontmatter["title"]:
            self.warnings.append(
                f"{file_path}: Title mismatch - "
                f"frontmatter: '{frontmatter['title']}', "
                f"H1: '{title_match.group(1)}'"
            )

        return True

    def _parse_frontmatter(self, fm_text: str) -> dict[str, str]:
        """Parse YAML-like frontmatter into a dict."""
        result = {}
        current_key = None
        current_list = []

        for line in fm_text.split("\n"):
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            if ":" in line and not line.startswith("-"):
                if current_key and current_list:
                    result[current_key] = current_list
                    current_list = []

                key, value = line.split(":", 1)
                key = key.strip()
                value = value.strip()

                if value:
                    result[key] = value
                else:
                    current_key = key
            elif line.startswith("-") and current_key:
                value = line[1:].strip().split("#")[0].strip()
                current_list.append(value)

        if current_key and current_list:
            result[current_key] = current_list

        return result

    def validate_uuid_references(self):
        """Validate that all UUID references in related/children exist."""
        valid_uuids = set(self.all_uuids.keys())

        for _uuid, file_path in self.all_uuids.items():
            with open(file_path, encoding="utf-8") as f:
                content = f.read()

            match = self.FRONTMATTER_PATTERN.match(content)
            if match:
                frontmatter = self._parse_frontmatter(match.group(1))

                # Check related UUIDs
                if "related" in frontmatter:
                    related = frontmatter["related"]
                    if isinstance(related, list):
                        for ref_uuid in related:
                            if ref_uuid and ref_uuid not in valid_uuids:
                                self.errors.append(
                                    f"{file_path}: Invalid UUID reference in 'related': {ref_uuid}"
                                )

                # Check children UUIDs
                if "children" in frontmatter:
                    children = frontmatter["children"]
                    if isinstance(children, list):
                        for ref_uuid in children:
                            if ref_uuid and ref_uuid not in valid_uuids:
                                self.errors.append(
                                    f"{file_path}: Invalid UUID reference in 'children': {ref_uuid}"
                                )


def main():
    # Parse command-line arguments
    parser = argparse.ArgumentParser(
        description="Validate YAML frontmatter in markdown files",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Validate single file
  %(prog)s document.md

  # Validate multiple files
  %(prog)s file1.md file2.md file3.md

  # Use custom config
  %(prog)s --config .ai/.frontmatter-ci.json document.md

  # Use custom cache file
  %(prog)s --cache /tmp/uuid-cache.json document.md

  # Use both custom config and cache
  %(prog)s --config custom.json --cache /tmp/cache.json document.md

  # Validate using glob pattern
  %(prog)s --glob '.ai/plans/**/*.md'
        """,
    )

    parser.add_argument(
        "files", nargs="*", metavar="FILE", help="Markdown files to validate"
    )

    parser.add_argument(
        "--config",
        "-c",
        metavar="PATH",
        default=".frontmatter-config.json",
        help="Path to config file (default: .frontmatter-config.json)",
    )

    parser.add_argument(
        "--glob",
        "-g",
        metavar="PATTERN",
        help='Glob pattern to match files (e.g., ".ai/**/*.md")',
    )

    parser.add_argument(
        "--cache",
        metavar="PATH",
        help="Path to UUID cache file (overrides config setting)",
    )

    args = parser.parse_args()

    # Determine files to validate
    files = []
    if args.glob:
        files = list(Path().glob(args.glob))
    elif args.files:
        files = [Path(f) for f in args.files]
    else:
        parser.error("No files specified. Provide files or use --glob")

    # Initialize validator with custom config and cache path (if specified)
    validator = FrontmatterValidator(config_path=args.config, cache_path=args.cache)

    # Prepare complete UUID map (cache-aware)
    # This discovers all UUIDs from configured directories,
    # enabling accurate cross-reference validation even with single file input
    validator.prepare_uuid_map()

    # Validate each file
    total = 0
    passed = 0

    for file_path in files:
        if file_path.exists() and file_path.suffix == ".md":
            total += 1
            if validator.validate_file(file_path):
                passed += 1

    # Validate UUID references (only if enabled in config)
    if validator.config["validation"]["validate_cross_references"]:
        validator.validate_uuid_references()

    # Print results
    print(f"\n{'=' * 60}")
    print("Frontmatter Validation Results")
    print(f"{'=' * 60}")
    print(f"Files validated: {total}")
    print(f"Passed: {passed}")
    print(f"Failed: {total - passed}")

    if validator.errors:
        print(f"\n❌ Errors ({len(validator.errors)}):")
        for error in validator.errors:
            print(f"  - {error}")

    if validator.warnings:
        print(f"\n⚠️  Warnings ({len(validator.warnings)}):")
        for warning in validator.warnings:
            print(f"  - {warning}")

    if not validator.errors and not validator.warnings:
        print("\n✅ All frontmatter is valid!")
        sys.exit(0)
    elif not validator.errors:
        print("\n✅ All frontmatter is valid (with warnings)")
        sys.exit(0)
    else:
        print("\n❌ Validation failed")
        sys.exit(1)


if __name__ == "__main__":
    main()
