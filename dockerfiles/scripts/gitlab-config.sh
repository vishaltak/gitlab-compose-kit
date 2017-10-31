#!/bin/bash

set -xe

cd /home/git/gitlab

echo gitlab_shell_secret > .gitlab_shell_secret

if ! bundle install --quiet --local --without production --jobs=$(nproc); then
  bundle install --without production --jobs=$(nproc)
fi

git config --global core.autocrlf input
git config --global gc.auto 0
git config --global repack.writeBitmaps true

/scripts/merge-yaml.rb config/gitlab.yml.example /dev/stdin > config/gitlab.yml <<EOF
development:
  gitlab:
    host: localhost
    port: 3000
  gitlab_shell:
    ssh_port: 2222
  pages:
    enabled: false
  mattermost:
    enabled: false
    host: 'https://mattermost.example.com'
  registry:
    enabled: true
    host: localhost
    port: 5000
    api_url: http://registry:5000/ # internal address to the registry, will be used by GitLab to directly communicate with API
    key: /home/git/registry-auth.key
    issuer: gitlab-issuer
    # path: shared/registry
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

if [[ ! -e /home/git/registry-auth.crt ]]; then
  openssl req -newkey rsa:2048 -x509 -nodes -days 3560 \
    -subj "/CN=gitlab.development.kit" \
    -out /home/git/registry-auth.crt -keyout /home/git/registry-auth.key
fi

# Workhorse secret has to be 32 bytes
echo -n 12345678901234567890123456789012 | base64 > .gitlab_workhorse_secret

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
