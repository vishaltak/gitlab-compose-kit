#!/bin/bash

set -xeo pipefail

if ! gem list -i bundler; then
    gem install bundler
fi

source /scripts/helpers/configure-gitlab-tracing.sh
source /scripts/helpers/configure-bundle-config.sh

/scripts/helpers/fix-perms.sh
/scripts/helpers/configure-gitlab-shell.sh

exec "$@"
