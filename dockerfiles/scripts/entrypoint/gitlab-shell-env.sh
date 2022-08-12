#!/bin/bash

set -xeo pipefail

if ! gem list -i bundler; then
    gem install bundler
fi

/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh

source /scripts/helpers/configure-gitlab-tracing.sh
source /scripts/helpers/configure-bundle-config.sh
source /scripts/helpers/configure-gitaly-version-fix.sh

/scripts/helpers/configure-gitlab-shell.sh

exec "$@"
