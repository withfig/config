#!/usr/bin/env bash

# We use a shell variable to make sure this doesn't load twice
if [[ -z "${FIG_SHELL_VAR}" ]]; then
  source ~/.fig/shell/post.sh
  FIG_SHELL_VAR=1
fi
