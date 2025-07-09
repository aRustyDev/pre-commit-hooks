#!/usr/bin/env bash

# TODO: Pull version from tags
# TODO: Handle commitizen-branch hook
# Package.json needs to be here or npm needs to run install
if ! [ -f ".cz.toml" ] && ! [ -f "cz.toml" ]; then
  pip install -U commitizen
  cat > .cz.toml << EOF
[tool.commitizen]
version = "0.1.0"
update_changelog_on_bump = true
EOF
  cz init
fi

# Run commitizen
cz check "$1"
