#!/usr/bin/env bash

# The `CUSTOM_ENV` contains a bash compatible export
# of environment variables from host system that are
# changed by `Makefile`

(
  set +x # hide output of `echo`
  set -eo pipefail

  if [[ ! -v CUSTOM_CONFIG ]] || [[ ! -v CUSTOM_ENV ]]; then
    echo "The required CUSTOM_CONFIG or CUSTOM_ENV is not set." 1>&2
    exit 1
  fi

  echo "$CUSTOM_CONFIG" | sponge /tmp/gck-custom.yml
  echo "$CUSTOM_ENV" | sponge /tmp/gck-custom.env
)

source /tmp/gck-custom.env
