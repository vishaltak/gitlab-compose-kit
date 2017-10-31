#!/bin/bash

set -xe

cd /home/git/gitlab

if ! bundle install --quiet --local --without production mysql sqlite3 --jobs=$(nproc); then
  bundle install --without production mysql sqlite3 --jobs=$(nproc)
fi

git config --global core.autocrlf input
git config --global gc.auto 0
git config --global repack.writeBitmaps true

/scripts/merge-yaml.rb config/gitlab.yml.example /dev/stdin > config/gitlab.yml <<EOF
development:
  gitlab:
    host: localhost
    port: 3000
  pages:
    enabled: false
  mattermost:
    enabled: false
    host: 'https://mattermost.example.com'
  registry:
    # enabled: true
    # host: registry.example.com
    # port: 5005
    # api_url: http://localhost:5000/ # internal address to the registry, will be used by GitLab to directly communicate with API
    # key: config/registry.key
    # path: shared/registry
    # issuer: gitlab-issuer
  repositories:
    storages:
      default:
        path: /home/git/repositories/
        gitaly_address: tcp://gitaly:9999
  webpack:
    dev_server:
      enabled: true
      host: webpack
      port: 3808
EOF

echo "secret" > .gitlab_workhorse_secret

if [[ ! -e config/secrets.yml ]]; then
  cp config/secrets.yml.example config/secrets.yml
fi

sed \
  -e 's|^worker_processes .*$|worker_processes 2|' \
  -e 's|^listen$|# listen|' \
  -e 's|^listen .*$|listen "0.0.0.0:8080", :tcp_nopush => true|' \
  config/unicorn.rb.example > config/unicorn.rb

cat <<EOF > config/resque.yml
production: &production
  url: redis://redis:6379
development: *production
test: *production
EOF

cat <<EOF > config/database.yml
production: &production
  adapter: postgresql
  encoding: unicode
  database: gitlabhq_production
  pool: 10
  username: postgres
  password: password
  host: postgres

development:
  <<: *production
  database: gitlabhq_development
  pool: 5

staging:
  <<: *production
  database: gitlabhq_staging
  pool: 5

test: 
  <<: *production
  database: gitlabhq_test
  pool: 5
EOF

cp -u config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

mkdir -p public/uploads/
