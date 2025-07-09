#!/usr/bin/env bash

# Package.json needs to be here or npm needs to run install
if ! [ -f "package.json" ]; then
  pip install gitlint
fi

# Run gitlint
gitlint --staged --msg-filename "$1"
