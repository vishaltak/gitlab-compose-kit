#!/bin/bash

# The `CUSTOM_ENV` contains a content of `gck.env`
# Those variables are converted into bash format
# and included as environment variables

# convert
#   export USE_WEBPACK_DEV=false
#   #export USE_TRACING=jaeger
#   export ADDITIONAL_DEPS="jq gdb"
#   DEBUG_CROSS_DB=1
# into:
#   export USE_WEBPACK_DEV="false"
#   export ADDITIONAL_DEPS="jq gdb"
#   export DEBUG_CROSS_DB="1"

(
  set +x # hide output of `echo`
  set -eo pipefail

  echo "$CUSTOM_CONFIG" | sponge /tmp/gck-custom.yml
  echo "$CUSTOM_ENV" | sed -n 's/^[ \t]*\(export\)\?[ \t]*\(\w\+\)[ \t]*=[ \t]*\([^"]*\)[ \t]*$/export \2="\3"/gp' |
    sponge /tmp/gck-custom.env
)

source /tmp/gck-custom.env
