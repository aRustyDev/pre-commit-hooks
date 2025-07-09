#!/usr/bin/env bash

# Package.json needs to be here or npm needs to run install
if ! [ -f "package.json" ]; then
  npm install --save-dev eslint @eslint/js
fi

# If no eslint.config.js is present, then use a default public one
if ! [ -f ".eslint.config.js" ] && ! [ -f ".eslint.config.mjs" ]; then
  npm init @eslint/config@latest -- --config eslint-config-standard
else
  npm init @eslint/config@latest
fi

# Run eslint
eslint "$1"
