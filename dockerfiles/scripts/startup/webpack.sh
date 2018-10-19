#!/bin/bash

set -xe

/scripts/helpers/fix-perms.sh

cd /home/git/gitlab

mkdir -p /data/cache/node_modules
ln -sf /data/cache/node_modules || true

# migrate old path
if [[ -d tmp/cache ]]; then
  rm -rf tmp/cache
fi

mkdir -p /data/cache/gitlab/cache
ln -sf /data/cache/gitlab/cache tmp/

yarn install
exec yarn dev-server
