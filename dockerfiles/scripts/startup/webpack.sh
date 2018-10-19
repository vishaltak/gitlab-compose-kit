#!/bin/bash

set -xe

/scripts/helpers/fix-perms.sh

cd /home/git/gitlab
mkdir -p /data/cache/node_modules
ln -sf /data/cache/node_modules || true

yarn install
exec yarn dev-server
