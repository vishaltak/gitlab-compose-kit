#!/bin/bash

source /scripts/helpers/configure-jemalloc2.sh

cd /home/git/gitlab
exec bin/background_jobs start_foreground -e "$RAILS_ENV" "$@"
