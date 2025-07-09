#!/usr/bin/env nix-shell
#!nix-shell default.nix -A expEnv -i bash
# shellcheck shell=bash

nix-build "$@"
