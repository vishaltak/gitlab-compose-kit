#!/bin/bash

set -xe

export BUNDLE_JOBS=$(nproc)

cd /home/git/gitlab-workhorse
make

# Workhorse secret has to be 32 bytes
echo -n 12345678901234567890123456789012 | base64 > /home/git/workhorse-secret

cat <<EOF > /home/git/workhorse-config.toml
[redis]
URL = "tcp://redis:6379"
EOF

export PATH="$PWD:$PATH"

./gitlab-workhorse \
  -authBackend="http://unicorn:8080/" \
  -developmentMode \
  -listenAddr="0.0.0.0:8181" \
  -documentRoot="/home/git/gitlab/public" \
  -config="/home/git/workhorse-config.toml" \
  -secretPath="/home/git/workhorse-secret" \
  "$@"
