#!/usr/bin/env bash

set -xeo pipefail

cd /home/git/gitlab

if ! bundle install --quiet --local; then
  bundle install
fi

git config --global core.autocrlf input
git config --global gc.auto 0
git config --global repack.writeBitmaps true
git config --add safe.directory /home/git/gitlab

/scripts/helpers/merge-yaml.rb config/gitlab.yml.example /scripts/templates/gitlab.yml /tmp/gck-custom.yml:gitlab.yml |
  sponge config/gitlab.yml

if [[ "$ENABLE_PRAEFECT" == "1" ]]; then
  /scripts/helpers/merge-yaml.rb config/gitlab.yml.example \
    /scripts/templates/gitlab.yml \
    /scripts/templates/gitlab-praefect.yml \
    /tmp/gck-custom.yml:gitlab.yml |
    sponge config/gitlab.yml
else
  /scripts/helpers/merge-yaml.rb config/gitlab.yml.example \
    /scripts/templates/gitlab.yml \
    /tmp/gck-custom.yml:gitlab.yml |
    sponge config/gitlab.yml
fi

if [[ ! -e /home/git/registry-auth.crt ]]; then
  openssl req -newkey rsa:2048 -x509 -nodes -days 3560 \
    -subj "/CN=gitlab.development.kit" \
    -out /home/git/registry-auth.crt -keyout /home/git/registry-auth.key
fi

if [[ ! -e config/secrets.yml ]]; then
  cp /scripts/templates/gitlab-secrets.yml config/secrets.yml
fi

/scripts/helpers/merge-yaml.rb /scripts/templates/gitlab-redis.yml /tmp/gck-custom.yml:resque.yml |
  sponge config/resque.yml

# Drop all existing redis.[store].yml files because they might be lingering from
# previous runs if CUSTOM_REDIS_ALT_STORE changed to a new store name.
rm -f config/redis.*.yml
for alt_store in ${CUSTOM_REDIS_ALT_STORE}; do
  /scripts/helpers/merge-yaml.rb /scripts/templates/gitlab-redis-alt.yml /tmp/gck-custom.yml:redis.${alt_store}.yml |
    sponge config/redis.${alt_store}.yml
done

# Configure Rails to share "some" state between Cells
if [[ -n "$CELL" ]]; then
  for shared_state in ${CUSTOM_REDIS_CLUSTER_STORE}; do
    /scripts/helpers/merge-yaml.rb /scripts/templates/gitlab-redis-cluster.yml /tmp/gck-custom.yml:redis.${shared_state}.yml |
      sponge "config/redis.$shared_state.yml"
  done
fi

/scripts/helpers/merge-yaml.rb /scripts/templates/gitlab-database.yml /tmp/gck-custom.yml:database.yml |
  sponge config/database.yml

/scripts/helpers/merge-yaml.rb /scripts/templates/gitlab-cable.yml /tmp/gck-custom.yml:cable.yml |
  sponge config/cable.yml

mkdir -p public/uploads/
