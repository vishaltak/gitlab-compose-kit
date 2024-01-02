#!/usr/bin/env bash

source /scripts/helpers/configure-custom-env.sh

/scripts/helpers/wait-for-service.sh file gitlab-rails-env /tmp/gitlab-rails-env-started || exit 1
/scripts/helpers/wait-for-service.sh tcp gitaly 10000 || exit 1

if [[ -z "$CHROME_HEADLESS" ]]; then
  if [[ -n "$DISPLAY" ]]; then
    export CHROME_HEADLESS=false
    echo 'Running in `export CHROME_HEADLESS=false` mode.'
  else
    export CHROME_HEADLESS=true
    echo 'Running in `export CHROME_HEADLESS=true` mode: as the `$DISPLAY` is missing.'
  fi
fi

if [[ -z "$WEBDRIVER_HEADLESS" ]]; then
  if [[ -n "$DISPLAY" ]]; then
    export WEBDRIVER_HEADLESS=false
    echo 'Running in `export WEBDRIVER_HEADLESS=false` mode.'
  else
    export WEBDRIVER_HEADLESS=true
    echo 'Running in `export WEBDRIVER_HEADLESS=true` mode: as the `$DISPLAY` is missing.'
  fi
fi


source /scripts/helpers/configure-gitlab-tracing.sh
source /scripts/helpers/configure-bundle-config.sh
source /scripts/helpers/configure-gitaly-version-fix.sh

echo

# Detect old paths and write warning about them
shopt -s nullglob # to resolve `bundle-*` to empty list

for path in /data/cache/bundle-*; do
    [[ "$path" == "$GEM_HOME" ]] && continue

    echo "!!! $path detected !!!"
    echo "Since it was used by older versions of Ruby"
    echo "consider removing to recycle disk space with:"
    echo "$ rm -r $path"
    echo ""
done

shopt -u nullglob

exec "$@"
