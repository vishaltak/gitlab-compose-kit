#!/bin/bash

# migrate old paths
pushd /home/git/gitlab

if [[ -d tmp/tests ]]; then
  rm -rf tmp/tests
fi

mkdir -p /data/cache/node_modules
ln -sf /data/cache/node_modules || true

mkdir -p /data/cache/gitlab/cache
ln -sf /data/cache/gitlab/cache tmp/ || true

mkdir -p /data/cache/gitlab/tests
ln -sf /data/cache/gitlab/tests tmp/ || true

popd

exit 0
