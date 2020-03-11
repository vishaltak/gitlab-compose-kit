#!/bin/bash

echo -n "Waiting for gitlab-rails env"
for i in $(seq 1 1000); do
  if [[ -f /tmp/gitlab-rails-env-started ]]; then
    break
  fi

  echo -n "."
  sleep 1s
done
echo " Done"

echo -n "Waiting for gitaly"
for i in $(seq 1 1000); do
  if timeout 1 bash -c "</dev/tcp/gitaly/9999" 2>/dev/null; then
    break
  fi

  echo -n "."
  sleep 1s
done
echo " Done"

source /scripts/helpers/configure-gitlab-rails-gemfile.sh
source /scripts/helpers/configure-gitlab-tracing.sh

exec "$@"
