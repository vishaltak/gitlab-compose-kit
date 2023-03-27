#!/bin/bash

# The `CUSTOM_ENV` contains a bash compatible export
# of environment variables from host system that are
# changed by `Makefile`

(
  set +x # hide output of `echo`
  set -eo pipefail

  echo "$CUSTOM_CONFIG" | sponge /tmp/gck-custom.yml
  echo "$CUSTOM_ENV" | sponge /tmp/gck-custom.env
)

source /tmp/gck-custom.env
