#!/usr/bin/env bash

# If /etc/nixos exists, copy it to the git repo
if [ -d "/etc/nixos" ]; then
  GIT_DIR=$(git rev-parse --show-toplevel)
  mkdir -p "$GIT_DIR/nixos/WIP"
  cp -a /etc/nixos/. "/$GIT_DIR/nixos/WIP/"
  git add "$GIT_DIR/nixos/WIP"
fi
