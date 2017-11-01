#!/bin/bash

set -xe

cd /home/git/gitlab
mkdir -p /data/cache/node_modules
ln -sf /data/cache/node_modules || true

yarn install
exec yarn dev-server
