#!/usr/bin/env bash

# Package.json needs to be here or npm needs to run install
if ! [ -f "package.json" ]; then
  npm install --save-dev jshint
fi

# Run jshint
jshint "$1"
