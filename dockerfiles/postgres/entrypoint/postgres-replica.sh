#!/usr/bin/env bash

set -eo pipefail

if [ "$(id -u)" = '0' ]; then
  # then restart script as postgres user
  exec su-exec postgres "$BASH_SOURCE" "$@"
fi

export PGUSER=postgres
export PGPASSWORD=password

echo "PGDATA: $PGDATA"

if [[ ! -e "$PGDATA" ]]; then
  echo "Replicating database..."
  pg_basebackup -h postgres -D "$PGDATA" -Fp -Xs -R
  echo "Done."
fi

echo "Starting postgress with delayed replication by ${POSTGRES_REPLICATION_LAG}ms..."
exec postgres -c "recovery_min_apply_delay=${POSTGRES_REPLICATION_LAG}"
