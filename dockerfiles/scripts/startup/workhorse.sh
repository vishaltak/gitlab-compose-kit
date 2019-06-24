#!/bin/bash

set -xe

export BUNDLE_JOBS=$(nproc)
export BUILD_DIR=/tmp/gitlab-workhorse

cd /home/git/gitlab-workhorse
make

# Workhorse secret has to be 32 bytes
echo -n 12345678901234567890123456789012 | base64 > /home/git/workhorse-secret

cat <<EOF > /home/git/workhorse-config.toml
[redis]
URL = "tcp://redis:6379"
EOF

export PATH="$BUILD_DIR:$PATH"

/tmp/gitlab-workhorse/gitlab-workhorse \
  -authBackend="http://${USE_WEB_SERVER}:8080/" \
  -developmentMode \
  -listenAddr="0.0.0.0:8181" \
  -documentRoot="/home/git/gitlab/public" \
  -config="/home/git/workhorse-config.toml" \
  -secretPath="/home/git/workhorse-secret" \
  "$@"
