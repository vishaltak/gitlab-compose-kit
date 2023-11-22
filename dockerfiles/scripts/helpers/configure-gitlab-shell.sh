#!/bin/bash

set -xeo pipefail

cd /home/git/gitlab-shell

rm -f .gitlab_shell_secret
/scripts/helpers/merge-yaml.rb config.yml.example /scripts/templates/gitlab-shell-config.yaml | sponge config.yml

# gitlab-rails or another container could be marking this directory as safe
git config --add safe.directory /home/git/gitlab-shell || true

if [[ "$(git describe)" == "$(cat /home/git/gitlab-shell-done || true)" ]]; then
  exit 0
fi

set -xeo pipefail
make setup

git describe | sponge /home/git/gitlab-shell-done
