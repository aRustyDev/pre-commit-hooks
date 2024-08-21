#!/usr/bin/env bash
# shellcheck shell=bash

OS=$(uname -s | tr '[:upper:]' '[:lower:]')

get_latest_release() {
  # Set the path to the pluralith binary
  if [ -z "$1" ]; then
    PLURAL_PATH="/usr/local/bin/pluralith"
  else
    PLURAL_PATH="$1"
  fi

  # 1. Use the GitHub API to get the latest release
  # 2. Use grep to find the line with the right download URL
  # 3. Use cut to get the URL
  # 4. Use tr to remove quotes
  URL=$(curl -s https://api.github.com/repos/Pluralith/pluralith-cli/releases/latest |
    grep "browser_download_url.*pluralith_cli_${OS}_amd64" |
    cut -d : -f 2,3 |
    tr -d \")
  # 5. Use cut to get the version
  VERSION="$(echo "$URL" | cut -d / -f 8)"
  # 6. Use wget to download the file
  wget -qi "$URL" -O pluralith
  # 7. Use mv to simultaneously place pluralith in the PATH & rename it
  mv pluralith "$PLURAL_PATH"
  # 8. Use chmod to make the file executable
  chmod +x "$PLURAL_PATH"
  # 9. Echo the version as the return value
  echo "$VERSION" | grep -o "[0-9\.]*"
}

get_current_version() {
  pluralith version | grep "CLI Version" | cut -d " " -f 4
}

# If pluralith is not installed, get the latest release || update
if ! command -v pluralith &> /dev/null; then
  get_latest_release > /dev/null # since it returns the version
elif [ "$(get_current_version)" != "$(get_latest_release)" ]; then
  PLURAL_PATH="$(which pluralith)"
  rm "$PLURAL_PATH"
  get_latest_release "$PLURAL_PATH" > /dev/null # since it returns the version
fi

# TODO: Make version bumpable
# Check if the config file exists; create it if it doesn't
if ! [ -f ".pluralith.yml" ] && ! [ -f ".pluralith.yaml" ]; then
  cat << EOF > ".pluralith.yaml"
#  _
# |_)|    _ _ |._|_|_
# |  ||_|| (_||| | | |
#
# Welcome to Pluralith!
# https://www.pluralith.com
#
# This is your Pluralith config file
# Learn more about it at https://docs.pluralith.com/docs/more/config

org_id: # REQUIRED - ID of an existing Pluralith organization. Can be found in your dashboard.
project_id: # REQUIRED - ID for your project. If no project exists with given ID, a new one is created. Otherwise runs get pushed to existing project. (Can only contain lowercase letters, numbers and dashes (-)).
project_name: # # REQUIRED - Name for your project. Will be used to create a new project if no project with previously specified ID exists yet.

config: # OPTIONAL - Various configurations for Terraform and Infracost under the hood
  title: # Title to be shown in the exported diagram PDF
  version: "v1.0.0" # Version to be shown in the exported diagram PDF
  sync_to_backend: false # Specify whether to store a diagram as PDF in your state backend alongside your Terraform state
  sensitive_attrs: # Specify which (sensitive) attributes the CLI should filter before generating the diagram
    - "attribute_name"
    - "attribute_name"
  vars: # Specify variables to be passed to Terraform under the hood
    - "NAME=VALUE"
    - "NAME=VALUE"
  var_files: # Specify paths to variable files to be passed to Terraform under the hood
    - "./var_file.tfvars"
    - "./var_file.tfvars"
  cost_usage_file: "./usage_file.yml" # Specify a path to an infracost usage file

diagram: # See https://docs.pluralith.com/docs/more/diagram-customization for all options
  hide:
    - resourceType
    - resourceType.resourceName
EOF
fi

# Run pluralith
if [ "$#" -eq 0 ]; then
  # This will only load the graph locally
  pluralith graph --local-only
else
  # TODO: Validate the API key
  # This will load the graph to the Pluralith cloud
  pluralith login --api-key "$1"
  pluralith graph
fi
