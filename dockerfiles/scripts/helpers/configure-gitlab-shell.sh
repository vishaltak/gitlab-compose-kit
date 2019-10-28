#!/bin/bash

set -xe

cd /home/git/gitlab-shell

rm -f .gitlab_shell_secret
echo gitlab_shell_secret > /home/git/shell-secret

if [[ "$(git describe)" == "$(cat /home/git/gitlab-shell-done || true)" ]]; then
  exit 0
fi

set -xe

/scripts/helpers/merge-yaml.rb config.yml.example /dev/stdin > config.yml <<EOF
gitlab_url: "http://${USE_WEB_SERVER}:8080/"
secret_file: /home/git/shell-secret
redis:
  host: redis
  port: 6379
  socket: nil
EOF

make setup

git describe > /home/git/gitlab-shell-done
