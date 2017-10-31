#!/bin/bash

set -xe

/scripts/gitlab-shell.sh

cd /home/git/gitlab-workhorse
make

# Workhorse secret has to be 32 bytes
echo -n 12345678901234567890123456789012 | base64 > .gitlab_workhorse_secret

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
