#!/bin/bash

set -xe

cd /home/git/gitlab-shell

mkdir -p ~/status

rm -f .gitlab_shell_secret
echo gitlab_shell_secret > .gitlab_shell_secret

if [[ "$(git describe)" == "$(cat ~/status/gitlab-shell || true)" ]]; then
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

git describe > ~/status/gitlab-shell
