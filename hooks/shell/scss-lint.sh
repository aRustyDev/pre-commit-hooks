#!/usr/bin/env bash

# Package.json needs to be here or npm needs to run install
if ! [ -f "package.json" ]; then
  gem install scss_lint
fi

# Run scss-lint
scss-lint "$1"
