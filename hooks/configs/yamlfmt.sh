#!/usr/bin/env bash

# Set local GOPATH
ORIG_GOPATH=$GOPATH
export GOPATH=$PWD

# Install the binary
if ! command -v yamlfmt > /dev/null 2>&1; then
  go install github.com/google/yamlfmt/cmd/yamlfmt@latest
fi

# Run yamlfmt
yamlfmt "$1"

# Cleanup
export GOPATH=$ORIG_GOPATH
