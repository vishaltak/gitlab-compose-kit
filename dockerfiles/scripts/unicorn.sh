#!/bin/bash

/scripts/fix-perms.sh
/scripts/gitlab-shell.sh
/scripts/gitlab-config.sh
/scripts/gitlab-gettext.sh

cd /home/git/gitlab
exec bundle exec unicorn -E "$RAILS_ENV" -c config/unicorn.rb
