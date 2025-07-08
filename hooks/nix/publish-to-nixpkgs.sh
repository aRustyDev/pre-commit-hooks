#!/usr/bin/env nix-shell
#!nix-shell default.nix -A expEnv -i bash

# TODO: pull the commit-msg from upstream
# TODO: commitlint the commit-msg

nix-build "$@"
git clone https://github.com/NixOS/nixpkgs
cd nixpkgs
mkdir -p pkgs/by-name/so/some-package
emacs pkgs/by-name/so/some-package/package.nix
git add pkgs/by-name/so/some-package/package.nix
nix-build -A some-package

# Best practice
# {
#   src = fetchFromGitHub {
#     owner = "NixOS";
#     repo = "nix";
#     rev = "1f795f9f44607cc5bec70d1300150bfefcef2aae";
#     hash = "sha256-7D4m+saJjbSFP5hOwpQq2FGR2rr+psQMTcyb1ZvtXsQ=";
#   };
# }
