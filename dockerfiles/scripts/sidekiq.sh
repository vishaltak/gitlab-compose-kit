#!/bin/bash

set -xe

/scripts/gitlab-shell.sh
/scripts/gitlab-config.sh
/scripts/gitlab-gettext.sh

cd /home/git/gitlab
exec bundle exec sidekiq -C "config/sidekiq_queues.yml" -e "$RAILS_ENV" "$@"
