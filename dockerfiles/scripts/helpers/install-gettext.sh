#!/bin/bash

set -xe

cd /home/git/gitlab

if [[ -e ~/gettext-done ]]; then
  bundle exec rake gettext:pack RAILS_ENV=production
  bundle exec rake gettext:po_to_json RAILS_ENV=production
  touch ~/gettext-done
fi
