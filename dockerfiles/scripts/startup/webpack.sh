#!/bin/bash

set -xeo pipefail

/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh

cd /home/git/gitlab

run_yarn='yarn -s'

# force compilation of webpack
if [[ "${FORCE_WEBPACK_COMPILE}" == "true" ]]; then
  echo "Webpack forced compilation!"
  ${run_yarn} install
  ${run_yarn} webpack
  echo "$GITLAB_RAILS_REVISION" | sponge /home/git/webpack-done
  exit 0
fi

# run webpack dev-server
if [[ "${USE_WEBPACK_DEV}" == "true" ]]; then
  echo "Webpack dev-server enabled with hotreload!"
  ${run_yarn} install
  exec ${run_yarn} dev-server
fi

echo 'Webpack dev-server disabled!'
echo 'use `export USE_WEBPACK_DEV=true` to enable hotreload!'

if [[ "$GITLAB_RAILS_REVISION" == "$(cat /home/git/webpack-done || true)" ]]; then
  echo "Webpack resources are up-to date ($GITLAB_RAILS_REVISION)."
  exit 0
fi

echo "New version of resources ($GITLAB_RAILS_REVISION) detected, recompiling..."
${run_yarn} install
${run_yarn} webpack
echo "$GITLAB_RAILS_REVISION" | sponge /home/git/webpack-done
echo "Done."
