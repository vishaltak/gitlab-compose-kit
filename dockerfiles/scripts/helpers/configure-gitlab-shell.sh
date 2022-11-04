#!/bin/bash

set -xeo pipefail

cd /home/git/gitlab-shell

rm -f .gitlab_shell_secret
echo gitlab_shell_secret | sponge /home/git/shell-secret

/scripts/helpers/merge-yaml.rb config.yml.example /dev/stdin <<EOF | sponge config.yml
gitlab_url: "http://workhorse:8181/"
secret_file: /home/git/shell-secret
log_file: "/home/git/gitlab-shell/gitlab-shell.log"
redis:
  host: redis
  port: 6379
  socket: nil
EOF

if [[ "$(git describe)" == "$(cat /home/git/gitlab-shell-done || true)" ]]; then
  exit 0
fi

set -xeo pipefail

make setup

git describe | sponge /home/git/gitlab-shell-done
