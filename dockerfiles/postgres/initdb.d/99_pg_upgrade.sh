#!/bin/bash

set -eo pipefail

pushd /tmp

# Convert from `/var/lib/postgres/data` to `/var/lib/postgres/data/<version>`
if [[ -s "$PGROOT/PG_VERSION" ]]; then
  export PGNEW="$PGROOT/$(cat "$PGROOT/PG_VERSION")"

  if [[ -d "$PGNEW" ]]; then
    echo "The '$PGNEW' already exist. Cannot continue."
    echo "Remove this folder manually."
    exit 1
  fi

  # move everything except something that indicates a version
  echo "Moving the "$PGROOT" into "$PGNEW"..."
  mkdir -m 0700 -p "$PGNEW/"
  mv "$PGROOT"/[^0-9]* "$PGNEW/"
fi

# Migrate the `/var/lib/postgres/data/<old-version>`
if [[ -d "$PGROOT/9.6" ]]; then
  echo "Shutting down '$PGDATA'..."
  pg_ctl -D "$PGDATA" -m fast -w stop

  echo "Migrating the "$PGROOT/9.6" to "$PGDATA"..."
  pg_upgrade \
    -d "$PGROOT/9.6" -b /pg96/usr/local/bin \
    -D "$PGDATA" -B /usr/local/bin || \
    ( cat pg_upgrade_server.log; exit 1 )
  mv "$PGROOT/9.6" "$PGROOT/9.6-migrated"

  echo "Starting '$PGDATA'..."
  pg_ctl -D "$PGDATA" -w start
fi

popd
