#!/bin/bash

set -xeo pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )/.."

if [[ -e ruby/Gemfile ]]; then
  source $SCRIPT_DIR/helpers/configure-jemalloc2.sh

  pushd ruby
  if ! bundle install --quiet --local; then
    bundle install
  fi
  popd

  # ensure that we do not re-install all dependencies
  export BUNDLE_FLAGS=--local
fi

cd /home/git/gitaly
git config --add safe.directory /home/git/gitaly || true
make WITH_BUNDLED_GIT=YesPlease

if [[ -n "$FORCE_GITALY_COMPILE" ]]; then
  echo "Forced gitaly compile!"
  exit 0
fi

$SCRIPT_DIR/helpers/wait-for-service.sh tcp postgres 5432

cat <<EOF | PGHOST=postgres PGUSER=postgres PGPASSWORD=password psql
  SELECT 'CREATE DATABASE gitlab_prafect'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'gitlab_prafect')\gexec
EOF

_build/bin/praefect -config $SCRIPT_DIR/templates/gitaly-config.praefect.toml sql-migrate

$SCRIPT_DIR/startup/gitaly.sh 100 |& ts "gitaly-100: " &
$SCRIPT_DIR/startup/gitaly.sh 101 |& ts "gitaly-101: " &
$SCRIPT_DIR/startup/gitaly.sh 102 |& ts "gitaly-102: " &

_build/bin/praefect -config $SCRIPT_DIR/templates/gitaly-config.praefect.toml serve |& ts "praefect:   "
