#!/bin/bash

set -xe

DROP_PRIVILEGES=
if [[ $(id -u) -eq 0 ]]; then
    DROP_PRIVILEGES="su git -c"
fi

if ! $DROP_PRIVILEGES gem list -i bundler; then
    $DROP_PRIVILEGES gem install bundler
fi

$DROP_PRIVILEGES /scripts/helpers/fix-perms.sh
$DROP_PRIVILEGES /scripts/helpers/configure-gitlab-shell.sh

exec "$@"
