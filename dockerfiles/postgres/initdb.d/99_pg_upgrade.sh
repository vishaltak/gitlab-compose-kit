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

for old_version in $UPGRADEABLE_PGVERSIONS; do
  # Migrate the `/var/lib/postgres/data/<old-version>`
  if [[ -d "$PGROOT/$old_version" ]]; then
    echo "Shutting down '$PGDATA'..."
    pg_ctl -D "$PGDATA" -m fast -w stop

    export LD_LIBRARY_PATH="/usr/lib:/lib:/postgres/$old_version/usr/lib:/postgres/$old_version/lib"

    echo "Migrating the '$PGROOT/$old_version' to '$PGDATA'..."
    pg_upgrade \
      -d "$PGROOT/$old_version" -b "/postgres/$old_version/usr/local/bin" \
      -D "$PGDATA" -B /usr/local/bin || \
      ( cat pg_upgrade_server.log; exit 1 )
    mv "$PGROOT/$old_version" "$PGROOT/$old_version-migrated"

    unset LD_LIBRARY_PATH

    echo "Starting '$PGDATA'..."
    pg_ctl -D "$PGDATA" -w start
  fi
done

popd
