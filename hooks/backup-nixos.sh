#!/usr/bin/env bash

if [ -d "/etc/nixos" ]; then
  mkdir -p "$GIT_DIR/nixos/WIP"
  cp -r /etc/nixos/ "$GIT_DIR/nixos/WIP/"
  git add "$GIT_DIR/nixos/WIP"
fi
