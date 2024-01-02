#!/usr/bin/env bash

pushd /home/git/gitlab >/dev/null

CACHE_DIR=/data/cache/gitlab

for cached in node_modules tmp/cache tmp/tests; do
  [[ -L "$cached" ]] && [[ -e "$cached" ]] && continue

  if [[ -d "$cached" ]]; then
    echo ">> The '$PWD/${cached}' already exists. This might lead to unoptimal performance. Remove to fix it."
    continue
  fi

  echo ">> Ensuring that '$PWD/${cached}' is cached..."
  name=$(basename "$cached")

  rm -rf "$cached"
  mkdir -p "$CACHE_DIR/$name"
  ln -sf "$CACHE_DIR/$name" "$cached"
done

popd >/dev/null

exit 0
