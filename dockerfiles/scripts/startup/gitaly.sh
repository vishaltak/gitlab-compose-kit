#!/bin/bash

set -xe

pushd ruby
if ! bundle install --quiet --local; then
  bundle install
fi
popd

# ensure that we do not re-install all dependencies
export BUNDLE_FLAGS=--local

cd /home/git/gitaly
make

sed \
  -e 's|^socket_path|# socket_path|' \
  -e 's|^# prometheus_listen_addr.*|prometheus_listen_addr = "0.0.0.0:9236"|' \
  -e 's|^# listen_addr.*|listen_addr = "0.0.0.0:9999"|' \
  -e 's|^path .*|path = "/data/repositories"|' \
  config.toml.example | sponge /home/git/gitaly-config.toml

exec ./gitaly /home/git/gitaly-config.toml
