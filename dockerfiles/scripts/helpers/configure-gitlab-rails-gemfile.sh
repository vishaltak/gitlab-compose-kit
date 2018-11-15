#!/bin/bash

case "$USE_RAILS" in
    rails4)
        echo "Using Rails 4 environment..."
        if [[ -e /home/git/gitlab/Gemfile.rails4.lock ]]; then
            export BUNDLE_GEMFILE=Gemfile.rails4
        fi
        ;;

    rails5)
        echo "Using Rails 5 environment..."
        if [[ -e /home/git/gitlab/Gemfile.rails5.lock ]]; then
            export BUNDLE_GEMFILE=Gemfile.rails5
        fi
        ;;

    *)
        echo "Unknown USE_RAILS=$USE_RAILS. Use rails4 or rails5."
        exit 1
        ;;
esac
