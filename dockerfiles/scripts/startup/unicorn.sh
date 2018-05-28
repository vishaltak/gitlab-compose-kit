#!/bin/bash

cd /home/git/gitlab

if [[ -n "$USE_RAILS_SERVER" ]]; then
    rm -f /tmp/rails-server.pid
    exec bundle exec rails server -b "0.0.0.0" -p 8080 -e "$RAILS_ENV" -P /tmp/rails-server.pid
else
    exec bundle exec unicorn -E "$RAILS_ENV" -c config/unicorn.rb
fi
