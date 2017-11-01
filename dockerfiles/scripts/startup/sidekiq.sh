#!/bin/bash

cd /home/git/gitlab
exec bundle exec sidekiq -C "config/sidekiq_queues.yml" -e "$RAILS_ENV" "$@"
