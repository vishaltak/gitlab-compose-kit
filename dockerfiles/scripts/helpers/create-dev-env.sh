#!/usr/bin/env bash

set -e

export ENABLE_SPRING=0
export SKIP_TEST_DATABASE=1 # make development not to change test

echo "Dropping data..."
rm -rf /data/repositories/* /data/shared/*
/scripts/helpers/fix-perms.sh
/scripts/helpers/fix-gitlab-tmp.sh

echo "Dropping database..."
bin/rake -t db:drop

echo "Dropping redis..."
redis-cli -h redis FLUSHALL

echo "Creating database..."
bin/rake -t db:prepare

echo "Seeding database..."
bin/rake -t dev:setup
