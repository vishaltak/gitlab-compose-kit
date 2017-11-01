#!/bin/bash

cd /home/git/gitlab

if [[ -n "$USE_RAILS_SERVER" ]]; then
    exec bundle exec rails server -b "0.0.0.0" -p 8080 -e "$RAILS_ENV"
else
    exec bundle exec unicorn -E "$RAILS_ENV" -c config/unicorn.rb
fi
