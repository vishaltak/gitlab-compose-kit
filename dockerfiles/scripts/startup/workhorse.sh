#!/usr/bin/env bash

set -xeo pipefail

export BUNDLE_JOBS=$(nproc)
export BUILD_DIR=/tmp/gitlab-workhorse

cd /home/git/gitlab/workhorse
make

export PATH="$BUILD_DIR:$PATH"

exec /tmp/gitlab-workhorse/gitlab-workhorse \
  -authBackend="http://web:8080/" \
  -cableBackend="http://web:8080/" \
  -developmentMode \
  -listenAddr="0.0.0.0:8181" \
  -prometheusListenAddr="0.0.0.0:9229" \
  -pprofListenAddr="0.0.0.0:6060" \
  -documentRoot="/home/git/gitlab/public" \
  -config="/scripts/templates/workhorse-config.toml" \
  -secretPath="/scripts/templates/workhorse-secret" \
  "$@"
