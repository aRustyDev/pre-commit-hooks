#!/usr/bin/env bash
# shellcheck shell=bash

# TODO: check if yq installed
# TODO: use yq to check versions

# integrations/github || aws
# terraform.required_providers.KEY || terraform.required_providers.KEY.source
PROVIDER=""
# terraform-aws-modules/vpc/aws
# git::https://example.com/vpc.git
# git::https://example\.com/.+
MODULE=""

ORIG_GOPATH="$(go env GOPATH)"
GOPATH="$(git rev-parse --show-toplevel)/.git/go"
mkdir -p "$GOPATH"

# Handle named flags
# -provider: Provider to update
# -module: Module to update
OPTLIST=$(getopt -n "$0" -a -l "provider:,module:" -- -- "$@")
eval set -- "$OPTLIST"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --provider)
      PROVIDER="$2"
      shift
      ;;
    --module)
      MODULE="$2"
      shift
      ;;
    --) shift ;;
  esac
  shift
done

# If tfupdate is not installed, get the latest release
if ! command -v tfupdate &> /dev/null; then
  go install github.com/minamijoyo/tfupdate@latest && sleep 1
else
  go install github.com/minamijoyo/tfupdate@latest && sleep 1
fi

if [ "$#" -eq 0 ]; then
  # updates terraform.required_version
  tfupdate terraform -r ./
  git add "./*provider.tf"
elif [ -n "$MODULE" ] && [ -n "$1" ]; then
  # updates module.*.version
  tfupdate module -r "$MODULE" "$1"
elif [ -n "$PROVIDER" ]; then
  # updates terraform.required_providers.aws
  tfupdate provider -r "$PROVIDER" "$1"
  git add "./*provider.tf"
fi

# Clean up
GOPATH="$ORIG_GOPATH"
