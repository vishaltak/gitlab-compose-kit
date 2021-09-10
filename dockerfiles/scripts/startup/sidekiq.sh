#!/bin/bash

cd /home/git/gitlab
exec bin/background_jobs start_foreground -e "$RAILS_ENV" "$@"
