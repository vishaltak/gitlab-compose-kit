#!/bin/bash

set -xe

/scripts/fix-perms.sh
/scripts/gitlab-shell.sh
/scripts/gitlab-config.sh
/scripts/gitlab-gettext.sh

exec "$@"
