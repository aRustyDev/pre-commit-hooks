#!/usr/bin/env bash

# TODO: check for action lint
# TODO: setup GOPATH locally
if ![ -f "package.json" ]; then
  go install github.com/rhysd/actionlint/cmd/actionlint@latest
fi

# Run actionlint
actionlint
