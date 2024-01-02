#!/usr/bin/env bash

source /scripts/helpers/configure-jemalloc2.sh

cd /home/git/gitlab

IFS=':'
read workers threads rest <<< "$CUSTOM_WEB_CONFIG"
workers="${workers:-2}"
threads="${threads:-4}"

if [[ "${USE_CABLE_SERVER}" == "true" ]]; then
  export ACTION_CABLE_IN_APP=true
fi

case "$USE_WEB_SERVER" in
    thin)
        echo "Starting Thin with single worker..."
        rm -f /tmp/rails-server.pid
        exec bundle exec rails server -b "0.0.0.0" -p 8080 -e "$RAILS_ENV" -P /tmp/rails-server.pid
        ;;

    puma)
        echo "Starting Puma with ${workers} workers and ${threads} threads..."
        exec bundle exec puma -e "$RAILS_ENV" -p 8080 --workers "${workers}" --threads "${threads}"
        ;;

    *)
        echo "Unknown web server: $USE_WEB_SEVER"
        exit 1
        ;;
esac
