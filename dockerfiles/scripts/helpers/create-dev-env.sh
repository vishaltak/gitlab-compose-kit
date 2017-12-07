#!/bin/bash

set -e

echo "Dropping data..."
rm -rf /data/repositories/* /data/shared/*
/scripts/helpers/fix-perms.sh

echo "Dropping database..."
bin/rake db:drop

echo "Dropping redis..."
redis-cli -h redis FLUSHALL

echo "Creating database..."
bin/rake db:create

echo "Creating data..."
bin/rake dev:setup
