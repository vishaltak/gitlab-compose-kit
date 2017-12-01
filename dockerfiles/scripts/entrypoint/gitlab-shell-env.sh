#!/bin/bash

set -xe

if ! gem list -i bundler; then
    gem install bundler
fi

/scripts/helpers/fix-perms.sh
/scripts/helpers/configure-gitlab-shell.sh

exec "$@"
