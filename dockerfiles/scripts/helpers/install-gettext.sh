#!/usr/bin/env bash

set -xeo pipefail

cd /home/git/gitlab

if [[ -e /home/git/gettext-done ]]; then
  bundle exec rake gettext:pack RAILS_ENV=production
  bundle exec rake gettext:po_to_json RAILS_ENV=production
  touch /home/git/gettext-done
fi
