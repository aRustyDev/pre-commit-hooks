#!/usr/bin/env bash

# 1. Check for Dependencies
if ! command -v pluralith &> /dev/null; then
  echo "pluralith binary not found"
  echo "Please install pluralith from"
  exit 1
fi
if [ ! command -v yq ] > /dev/null 2>&1; then
  echo "yq binary not found"
  echo "Downloading yq binary"
  go install github.com/mikefarah/yq/v4@latest
fi

pluralith graph --title "Mark I" --author "Tony Stark" --version "0.0.1" --show-changes

title: Mark I
author: Tony Stark
version: 0.0.1
