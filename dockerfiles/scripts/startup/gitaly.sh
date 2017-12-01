#!/bin/bash

set -xe

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
  config.toml.example > /home/git/gitaly-config.toml

./gitaly /home/git/gitaly-config.toml
