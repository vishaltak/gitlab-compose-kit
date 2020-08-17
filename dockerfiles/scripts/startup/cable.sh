#!/bin/bash
set -ex

cd /home/git/gitlab

if [[ "${USE_CABLE_SERVER}" == "in_app" ]]; then
  echo "ActionCable in-app mode is enabled!"
  exit 0
fi

# we only support puma for actioncable at this point
echo "[ActionCable] Starting Puma ..."

cp config/puma_actioncable.rb /tmp/puma_actioncable.rb || \
  cp config/puma_actioncable.example.development.rb /tmp/puma_actioncable.rb

exec bundle exec puma -e "$RAILS_ENV" -C /tmp/puma_actioncable.rb -p 8090
