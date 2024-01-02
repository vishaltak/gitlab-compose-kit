#!/usr/bin/env bash

set -xeo pipefail

UPGRADES_DIR=/home/git/gck-upgrades
mkdir -p "$UPGRADES_DIR"

if [[ ! -e "$UPGRADES_DIR/gitlab-dual-db-done" ]]; then
  echo ">> Running migration from a single DB to dual DB (main => main + CI). Data will be duplicated."

  /scripts/helpers/wait-for-service.sh tcp postgres 5432

  # Due to adding multiple databases in GCK by default
  # this is used to clone existing database to CI
  cat <<EOF | PGHOST=postgres PGUSER=postgres PGPASSWORD=password psql
    SELECT 'CREATE DATABASE gitlabhq_development_ci WITH TEMPLATE gitlabhq_development'
      WHERE EXISTS (SELECT FROM pg_database WHERE datname = 'gitlabhq_development') AND
        NOT EXISTS (SELECT FROM pg_database WHERE datname = 'gitlabhq_development_ci')\gexec

    SELECT 'CREATE DATABASE gitlabhq_staging_ci WITH TEMPLATE gitlabhq_staging'
      WHERE EXISTS (SELECT FROM pg_database WHERE datname = 'gitlabhq_staging') AND
        NOT EXISTS (SELECT FROM pg_database WHERE datname = 'gitlabhq_staging_ci')\gexec

    SELECT 'CREATE DATABASE gitlabhq_test_ee_ci WITH TEMPLATE gitlabhq_test_ee'
      WHERE EXISTS (SELECT FROM pg_database WHERE datname = 'gitlabhq_test_ee') AND
        NOT EXISTS (SELECT FROM pg_database WHERE datname = 'gitlabhq_test_ee_ci')\gexec
EOF

  touch "$UPGRADES_DIR/gitlab-dual-db-done"
  echo ">> Dual DB migration was done."
fi
