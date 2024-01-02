#!/usr/bin/env bash

set -eo pipefail

/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh

cd /home/git/gitlab

run_yarn='yarn -s'

# run webpack dev-server (the force compile still takes precedence)
if [[ "${USE_WEBPACK_DEV}" == "true" && "${FORCE_WEBPACK_COMPILE}" != "true" ]]; then
  export DEV_SERVER_LIVERELOAD=${DEV_SERVER_LIVERELOAD:-true}
  export DEV_SERVER_INCREMENTAL=${DEV_SERVER_INCREMENTAL:-true}

  echo "Webpack dev-server enabled (live-reload=${DEV_SERVER_LIVERELOAD} incremental=${DEV_SERVER_INCREMENTAL})"

  echo ">> Cleaning public/assets and tmp/cache/assets to fix hot reload..."
  git clean -qfdx public/assets
  rm -rf tmp/cache/assets

  echo ">> Installing nodejs packages..."
  ${run_yarn} install

  echo ">> Running webpack dev-server..."
  exec ${run_yarn} dev-server
  exit 0
fi

webpack_status="public/assets/webpack-done"

if [[ "${FORCE_WEBPACK_COMPILE}" == "true" ]]; then
  echo "Webpack forced compilation!"
elif [[ ! -f "$webpack_status" ]]; then
  echo "Webpack compilation is run for the first time."
elif [[ "$GITLAB_RAILS_REVISION" != "$(cat "$webpack_status" || true)" ]]; then
  echo "New version of resources ($GITLAB_RAILS_REVISION) detected, recompiling..."
else
  echo "Webpack resources are up-to date ($GITLAB_RAILS_REVISION)."
  exit 0
fi

echo '>> Use `export USE_WEBPACK_DEV=true` to enable hotreload!'

echo ">> Installing nodejs packages..."
${run_yarn} install

echo ">> Running webpack dev-server..."
${run_yarn} webpack

echo ">> Storing compilation version..."
echo "$GITLAB_RAILS_REVISION" | sponge "$webpack_status"
echo "Done."
