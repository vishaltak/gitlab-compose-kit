#!/bin/bash

set -xeo pipefail

pushd ruby
if ! bundle install --quiet --local; then
  bundle install
fi
popd

# ensure that we do not re-install all dependencies
export BUNDLE_FLAGS=--local

cd /home/git/gitaly
make WITH_BUNDLED_GIT=YesPlease

if [[ -n "$FORCE_GITALY_COMPILE" ]]; then
  echo "Forced gitaly compile!"
  exit 0
fi

# Remove: `gitlab_url=`
# - some older gitaly versions do break as they require `url`
# - will be fixed with https://gitlab.com/gitlab-org/gitaly/-/merge_requests/2240

sed \
  -e 's|^socket_path|# socket_path|' \
  -e 's|^# prometheus_listen_addr.*|prometheus_listen_addr = "0.0.0.0:9236"|' \
  -e 's|^# listen_addr.*|listen_addr = "0.0.0.0:9999"|' \
  -e 's|^path .*|path = "/data/repositories"|' \
  -e 's|^url .*|url = "http://web:8080"|' \
  -e 's|^secret_file .*|secret_file = "/home/git/shell-secret"|' \
  -e 's|^gitlab_url .*|url = "http://web:8080"|' \
  -e 's|^# \[git\]|[git]|' \
  -e 's|^# bin_path .*|use_bundled_binaries = true|' \
  config.toml.example | sponge /home/git/gitaly-config.toml

# Gitaly does not install into top-level dir anymore
# https://gitlab.com/gitlab-org/gitaly/-/commit/eb6fd60561cffdbb183e74456268439bad60b21c
if [[ -e _build/bin/gitaly ]]; then
  exec ./_build/bin/gitaly /home/git/gitaly-config.toml
else
  exec ./gitaly /home/git/gitaly-config.toml
fi
