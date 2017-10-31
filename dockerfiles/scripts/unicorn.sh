#!/bin/bash

cd /home/git/gitlab
exec bundle exec unicorn -E "$RAILS_ENV" -c config/unicorn.rb
