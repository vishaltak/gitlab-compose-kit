#!/usr/bin/env bash

set -xeo pipefail

if [[ -e ruby/Gemfile ]]; then
  source /scripts/helpers/configure-jemalloc2.sh

  pushd ruby
  if ! bundle install --quiet --local; then
    bundle install
  fi
  popd

  # ensure that we do not re-install all dependencies
  export BUNDLE_FLAGS=--local
fi

cd /home/git/gitaly
git config --add safe.directory /home/git/gitaly || true
make WITH_BUNDLED_GIT=YesPlease

if [[ -n "$FORCE_GITALY_COMPILE" ]]; then
  echo "Forced gitaly compile!"
  exit 0
fi

REPO_PATH="/data/repositories"
CONFIG_PATH="/tmp/gitaly-config.toml"
GITALY_PORT="10000"
PROMETHEUS_PORT="11000"
STORAGE_NAME="default"

if [[ -n "$1" ]]; then
  REPO_PATH="$REPO_PATH/@gitaly-$1"
  GITALY_PORT=$(($GITALY_PORT+$1))
  PROMETHEUS_PORT=$(($PROMETHEUS_PORT+$1))
  STORAGE_NAME="praefect-git-$1"
  CONFIG_PATH="/tmp/gitaly-config-$1.toml"
fi

mkdir -p "$REPO_PATH"

# Remove: `gitlab_url=`
# - some older gitaly versions do break as they require `url`
# - will be fixed with https://gitlab.com/gitlab-org/gitaly/-/merge_requests/2240
# TODO: merge toml files
sed \
  -e 's|^socket_path|# socket_path|' \
  -e "s|^# prometheus_listen_addr.*|prometheus_listen_addr = \"0.0.0.0:$PROMETHEUS_PORT\"|" \
  -e "s|^# listen_addr.*|listen_addr = \"0.0.0.0:$GITALY_PORT\"|" \
  -e "s|^path .*|path = \"$REPO_PATH\"|" \
  -e "s|^name .*|name = \"$STORAGE_NAME\"|" \
  -e 's|^url .*|url = "http://workhorse:8181"|' \
  -e 's|^secret_file .*|secret_file = "/scripts/templates/gitlab-shell-secret"|' \
  -e 's|^gitlab_url .*|url = "http://workhorse:8181"|' \
  -e 's|^# \[git\]|[git]|' \
  -e 's|^# bin_path .*|use_bundled_binaries = true|' \
  config.toml.example | sponge "$CONFIG_PATH"

# Gitaly does not install into top-level dir anymore
# https://gitlab.com/gitlab-org/gitaly/-/commit/eb6fd60561cffdbb183e74456268439bad60b21c
if [[ -e _build/bin/gitaly ]]; then
  exec ./_build/bin/gitaly "$CONFIG_PATH"
else
  exec ./gitaly "$CONFIG_PATH"
fi
