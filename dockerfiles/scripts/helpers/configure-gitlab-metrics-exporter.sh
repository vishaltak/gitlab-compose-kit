#!/bin/bash

set -xeo pipefail

LOCKFILE_DIR=/data/shared/scratch

mkdir -p $LOCKFILE_DIR

pushd /home/git/gitlab-metrics-exporter
PREFIX=/usr/local flock "${LOCKFILE_DIR}/gitlab-metrics-exporter.build.lock" make clean install
popd
