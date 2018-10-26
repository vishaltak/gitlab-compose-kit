#!/bin/bash

cd /home/git/gitlab

if [[ -n "$USE_RAILS_SERVER" ]]; then
    rm -f /tmp/rails-server.pid
    exec bundle exec rails server -b "0.0.0.0" -p 8080 -e "$RAILS_ENV" -P /tmp/rails-server.pid
else
    exec bundle exec unicorn_rails -E "$RAILS_ENV" -c config/unicorn.rb -l "0.0.0.0:8080"
fi
