#!/bin/bash

cd /home/git/gitlab

IFS=':'
read workers threads rest <<< "$CUSTOM_WEB_CONFIG"
workers="${workers:-2}"
threads="${threads:-4}"

case "$USE_WEB_SERVER" in
    thin)
        echo "Starting Thin with single worker..."
        rm -f /tmp/rails-server.pid
        exec bundle exec rails server -b "0.0.0.0" -p 8080 -e "$RAILS_ENV" -P /tmp/rails-server.pid
        ;;

    unicorn)
        echo "Starting Unicorn with ${workers} workers..."
        cp config/unicorn.rb.example.development /tmp/unicorn.rb
        echo "worker_processes $workers" >> /tmp/unicorn.rb
        exec bundle exec unicorn_rails -E "$RAILS_ENV" -c /tmp/unicorn.rb -l "0.0.0.0:8080"
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
