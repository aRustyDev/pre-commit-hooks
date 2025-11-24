#!/usr/bin/env bash

if [ -f ".csslintrc" ]; then
  echo "couldn't find .csslintrc"
  exit 1
fi

npm install -g csslint
csslint "$1"
