#!/bin/bash

if [[ ! -f ~/.bundle/config.created ]]; then
  bundle config set --global without production
  bundle config set --global silence_root_warning true
  bundle config set --global jobs "$(nproc)"
  bundle config set --global deployment false
  bundle config set --global user_home "$GEM_HOME/user-home"
  bundle config set --global path "${GEM_HOME}"
  touch ~/.bundle/config.created
fi

# This is needed by Gitaly as it uses custom HOME directory
ln -sf ~/.bundle /data/cache/gitlab/tests/
