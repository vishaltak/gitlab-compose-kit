#!/bin/bash

set -xe

cd /home/git/gitlab

mkdir -p ~/status

if [[ -e ~/status/gettext ]]; then
  bundle exec rake gettext:pack RAILS_ENV=production
  bundle exec rake gettext:po_to_json RAILS_ENV=production
  touch ~/status/gettext
fi
