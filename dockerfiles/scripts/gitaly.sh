#!/bin/bash

set -xe

/scripts/fix-perms.sh
/scripts/gitlab-shell.sh

cd /home/git/gitaly
make

sed \
  -e 's|^socket_path|# socket_path|' \
  -e 's|^# prometheus_listen_addr|prometheus_listen_addr|' \
  -e 's|^# listen_addr.*|listen_addr = "0.0.0.0:9999"|' \
  -e 's|^path .*|path = "/data/repositories"|' \
  config.toml.example > config.toml

./gitaly config.toml
