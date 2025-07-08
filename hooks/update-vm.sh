#!/usr/bin/env bash

if [ $(uname -n) == "nixos" ]; then
  cp "$GIT_DIR/nixos/WIP/*.nix" /etc/nixos/
fi
