#!/bin/bash

set -xe

# custom paths for gitaly
export GEM_HOME=/data/cache/gitaly-bundle
export BUNDLE_PATH="$GEM_HOME"
export BUNDLE_BIN="$GEM_HOME/bin"
export BUNDLE_APP_CONFIG="$GEM_HOME"
export PATH="$BUNDLE_BIN:$PATH"
export BUNDLE_JOBS=$(nproc)

cd /home/git/gitaly
make

pushd ruby
if ! bundle install --quiet --local; then
  bundle install
fi
popd

sed \
  -e 's|^socket_path|# socket_path|' \
  -e 's|^# prometheus_listen_addr|prometheus_listen_addr|' \
  -e 's|^# listen_addr.*|listen_addr = "0.0.0.0:9999"|' \
  -e 's|^path .*|path = "/data/repositories"|' \
  config.toml.example > /data/gitaly-config.toml

./gitaly /data/gitaly-config.toml
