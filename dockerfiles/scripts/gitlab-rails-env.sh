#!/bin/bash

set -xe

/scripts/gitlab-shell.sh
/scripts/gitlab-config.sh
/scripts/gitlab-gettext.sh

exec "$@"
