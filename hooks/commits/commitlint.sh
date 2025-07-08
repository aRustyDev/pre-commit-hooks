#!/usr/bin/env bash

# Package.json needs to be here or npm needs to run install
if ![ -f "package.json" ]; then
  npm install --save-dev @commitlint/{cli,config-conventional}
  # echo "export default { extends: ['@commitlint/config-conventional'] };" > commitlint.config.js
fi

# Run eslint
commitlint --edit $1
