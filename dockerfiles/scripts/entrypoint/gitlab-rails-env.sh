#!/bin/bash

set -xe

export BUNDLE_JOBS=$(nproc)

if ! gem list -i bundler; then
    gem install bundler
fi

/scripts/helpers/fix-perms.sh
/scripts/helpers/configure-gitlab-shell.sh
/scripts/helpers/configure-gitlab-rails.sh
/scripts/helpers/install-gettext.sh

exec "$@"
