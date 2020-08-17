#!/bin/bash

set -xe

export BUNDLE_JOBS=$(nproc)
export BUILD_DIR=/tmp/gitlab-workhorse

cd /home/git/gitlab-workhorse
make

# Workhorse secret has to be 32 bytes
echo -n 12345678901234567890123456789012 | base64 | sponge /home/git/workhorse-secret

cat <<EOF | sponge /home/git/workhorse-config.toml
[redis]
URL = "tcp://redis:6379"
EOF

if [[ "${USE_CABLE_SERVER}" == "in_app" ]]; then
  CABLE_BACKEND="http://web:8080"
else
  CABLE_BACKEND="http://cable:8090"
fi

export PATH="$BUILD_DIR:$PATH"

exec /tmp/gitlab-workhorse/gitlab-workhorse \
  -authBackend="http://web:8080/" \
  -cableBackend="${CABLE_BACKEND}" \
  -developmentMode \
  -listenAddr="0.0.0.0:8181" \
  -prometheusListenAddr="0.0.0.0:9229" \
  -documentRoot="/home/git/gitlab/public" \
  -config="/home/git/workhorse-config.toml" \
  -secretPath="/home/git/workhorse-secret" \
  "$@"
