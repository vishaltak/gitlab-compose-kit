#!/bin/bash

set -xeo pipefail

pushd /home/git/gitlab-metrics-exporter
PREFIX=/usr/local make install
popd
