#!/bin/bash

set -xe

cd /home/git/gitlab

echo gitlab_shell_secret > /home/git/shell-secret

if ! bundle install --quiet --local --without production --jobs=$(nproc); then
  bundle install --without production --jobs=$(nproc)
fi

git config --global core.autocrlf input
git config --global gc.auto 0
git config --global repack.writeBitmaps true

echo "$CUSTOM_CONFIG" > /home/git/gitlab-custom.yml

/scripts/helpers/merge-yaml.rb config/gitlab.yml.example /dev/stdin /home/git/gitlab-custom.yml > config/gitlab.yml <<EOF
development:
  gitlab:
    host: ${HOST}
    port: 3000
  gitlab_shell:
    ssh_port: 2222
    secret_file: /home/git/shell-secret
  workhorse:
    secret_file: /home/git/workhorse-secret
  pages:
    enabled: true
    host: gitlab-example.com
    port: 80 # Set to 443 if you serve the pages with HTTPS
    https: false # Set to true if you serve the pages with HTTPS
    artifacts_server: true
  mattermost:
    enabled: false
    host: 'https://mattermost.example.com'
  registry:
    enabled: true
    host: ${HOST}
    port: 5000
    api_url: http://registry:5000/ # internal address to the registry, will be used by GitLab to directly communicate with API
    key: /home/git/registry-auth.key
    issuer: gitlab-issuer
    # path: shared/registry
  repositories:
    storages:
      default:
        path: /data/repositories/
        gitaly_address: tcp://gitaly:9999
  artifacts:
    enabled: true
    path: /data/shared/artifacts
  lfs:
    enabled: true
    storage_path: /data/shared/lfs
  gitlab_ci:
    builds_path: /data/shared/builds
  pages:
    path: /data/shared/pages
  webpack:
    dev_server:
      enabled: true
      host: webpack
      port: 3808
  uploads:
    storage_path: /home/git/gitlab/public/
test:
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
echo -n 12345678901234567890123456789012 | base64 > /home/git/workhorse-secret

if [[ ! -e config/secrets.yml ]]; then
  cat > config/secrets.yml <<EOF
development:
  db_key_base: 9a138cf90aa854ba65b50a5e2e76b2acfb9dfd22d1df5ccb9e1ff5a6f9657e2c

test:
  db_key_base: 9a138cf90aa854ba65b50a5e2e76b2acfb9dfd22d1df5ccb9e1ff5a6f9657e2c
EOF
fi

sed \
  -e 's|^worker_processes .*$|worker_processes 2|' \
  -e 's|^listen$|# listen|' \
  -e 's|^listen .*$|listen "0.0.0.0:8080", :tcp_nopush => true|' \
  -e 's|^pid|# pid|g' \
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
  database: gitlabhq_test_<%= File.directory?(Rails.root.join('ee')) ? 'ee' : 'ce' %>
  pool: 5
EOF

cp -u config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

mkdir -p public/uploads/
