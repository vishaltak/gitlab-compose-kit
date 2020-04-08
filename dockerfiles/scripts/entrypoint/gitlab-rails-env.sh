#!/bin/bash

set -xe

export BUNDLE_JOBS=$(nproc)

if ! gem list -i bundler; then
    gem install bundler
fi

source /scripts/helpers/configure-gitlab-tracing.sh

/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh
/scripts/helpers/configure-gitlab-shell.sh
/scripts/helpers/configure-gitlab-rails.sh
/scripts/helpers/install-gettext.sh

touch /tmp/gitlab-rails-env-started

exec "$@"
