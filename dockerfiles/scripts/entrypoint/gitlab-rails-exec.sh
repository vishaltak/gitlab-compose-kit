#!/bin/bash

echo -n "Waiting for gitlab-rails env"
for i in $(seq 1 1000); do
  if [[ -f /tmp/gitlab-rails-env-started ]]; then
    break
  fi

  echo -n "."
  sleep 1s
done
echo " Done"

echo -n "Waiting for gitaly"
for i in $(seq 1 1000); do
  if timeout 1 bash -c "</dev/tcp/gitaly/9999" 2>/dev/null; then
    break
  fi

  echo -n "."
  sleep 1s
done
echo " Done"

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
