#!/bin/bash

set -xe

cd /home/git/gitlab
yarn install --modules-folder /data/cache/node_modules
exec yarn dev-server
