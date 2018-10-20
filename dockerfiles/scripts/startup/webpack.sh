#!/bin/bash

set -xe

if [[ "${ENABLE_WEBPACK_DEV:-false}" != "true" ]] && [[ -z "${COMPILE_WEBPACK}" ]]; then
  echo 'Webpack dev-server disabled!'
  echo 'use `export ENABLE_WEBPACK_DEV=true` to enable hotreload!'
  exit 1
fi

/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh

cd /home/git/gitlab

yarn install

if [[ -n "${COMPILE_WEBPACK}" ]]; then
  exec yarn webpack
fi

exec yarn dev-server
