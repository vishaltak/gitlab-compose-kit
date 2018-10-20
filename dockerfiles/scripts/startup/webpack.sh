#!/bin/bash

set -xe

/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh

cd /home/git/gitlab

# force compilation of webpack
if [[ -n "${FORCE_WEBPACK_COMPILE}" ]]; then
  echo "Webpack forced compilation!"
  yarn install
  yarn webpack
  echo "$GITLAB_RAILS_REVISION" > /home/git/webpack-done
  exit 0
fi

# run webpack dev-server
if [[ "${USE_WEBPACK_DEV}" == "true" ]]; then
  echo "Webpack dev-server enabled with hotreload!"
  yarn install
  exec yarn dev-server
fi

echo 'Webpack dev-server disabled!'
echo 'use `export ENABLE_WEBPACK_DEV=true` to enable hotreload!'

if [[ "$GITLAB_RAILS_REVISION" == "$(cat /home/git/webpack-done || true)" ]]; then
  echo "Webpack resources are up-to date ($GITLAB_RAILS_REVISION)."
  exec cat # hang forever
fi

echo "New version of resources ($GITLAB_RAILS_REVISION) detected, recompiling..."
yarn install
yarn webpack
echo "$GITLAB_RAILS_REVISION" > /home/git/webpack-done
echo "Done."
exec cat # hang forever
