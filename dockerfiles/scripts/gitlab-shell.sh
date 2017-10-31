#!/bin/sh

set -xe

cd /home/git/gitlab-shell

sed \
  -e 's|^gitlab_url.*$|gitlab_url: "http://unicorn:8080/"|' \
  -e 's|^# host.*$|host: redis|' \
  -e 's|^# port: 6379.*$|port: 6379|' \
  -e 's|^socket:|# socket:|' \
  -e 's|^# listen_addr|listen_addr = "|' config.yml.example > config.yml

./bin/install
./bin/compile

echo GitLab Shell configuration:
cat config.yml
