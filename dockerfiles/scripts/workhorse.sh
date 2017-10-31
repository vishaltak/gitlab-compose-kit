#!/bin/bash

set -xe

/scripts/gitlab-shell.sh

cd /home/git/gitlab-workhorse
make

echo "secret" > .gitlab_workhorse_secret

cat <<EOF > config.toml
[redis]
URL = "tcp://redis:6379"
EOF

export PATH="$PWD:$PATH"
./gitlab-workhorse \
  -authBackend="http://unicorn:8080/" \
  -developmentMode \
  -listenAddr="0.0.0.0:8181" \
  -config="config.toml" \
  "$@"
