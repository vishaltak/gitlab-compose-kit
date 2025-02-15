#!/usr/bin/env bash

set -xeo pipefail

if ! gem list -i bundler; then
    gem install bundler
fi

source /scripts/helpers/configure-custom-env.sh
source /scripts/helpers/configure-gitlab-tracing.sh
source /scripts/helpers/configure-bundle-config.sh
source /scripts/helpers/configure-gitaly-version-fix.sh

/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh
/scripts/helpers/configure-gitlab-shell.sh
/scripts/helpers/configure-gitlab-rails.sh
/scripts/helpers/install-gettext.sh
/scripts/helpers/upgrade-gck.sh

touch /tmp/gitlab-rails-env-started

exec "$@"
