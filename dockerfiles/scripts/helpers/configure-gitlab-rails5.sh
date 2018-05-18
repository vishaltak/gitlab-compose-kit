#!/bin/bash

if [[ -n "$USE_RAILS5" ]]; then
    echo "Using Rails 5 environment..."
    export BUNDLE_GEMFILE=Gemfile.rails5
    export RAILS5=1
fi
