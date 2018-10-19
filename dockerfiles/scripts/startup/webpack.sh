#!/bin/bash

set -xe

/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh

cd /home/git/gitlab

yarn install
exec yarn dev-server
