#!/bin/bash

cd /home/git/gitlab-shell

if [[ "$(git describe)" == "$(cat .done || true)" ]]; then
  exit 0
fi

set -xe

sed \
  -e 's|^gitlab_url.*$|gitlab_url: "http://unicorn:8080/"|' \
  -e 's|^# host.*$|host: redis|' \
  -e 's|^# port: 6379.*$|port: 6379|' \
  -e 's|^socket:|# socket:|' \
  -e 's|^# listen_addr|listen_addr = "|' config.yml.example > config.yml

./bin/install
./bin/compile

git describe > .done
