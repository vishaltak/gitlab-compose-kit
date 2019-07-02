#!/bin/bash

cd /home/git/gitlab

case "$USE_WEB_SERVER" in
    thin)
        rm -f /tmp/rails-server.pid
        exec bundle exec rails server -b "0.0.0.0" -p 8080 -e "$RAILS_ENV" -P /tmp/rails-server.pid
        ;;

    unicorn)
        exec bundle exec unicorn_rails -E "$RAILS_ENV" -c config/unicorn.rb -l "0.0.0.0:8080"
        ;;

    puma)
        exec bundle exec puma -e "$RAILS_ENV"  -p 8080 --workers 2 --threads 4
        ;;

    *)
        echo "Unknown web server: $USE_WEB_SEVER"
        exit 1
        ;;
esac
