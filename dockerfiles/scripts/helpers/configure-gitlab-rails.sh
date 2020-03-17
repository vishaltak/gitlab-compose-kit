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

echo "$CUSTOM_CONFIG" > /home/git/gck-custom.yml

/scripts/helpers/merge-yaml.rb config/gitlab.yml.example /dev/stdin /home/git/gck-custom.yml:gitlab.yml > config/gitlab.yml <<EOF
production: &production
  gitlab:
    host: ${CUSTOM_HOSTNAME}
    port: ${CUSTOM_WEB_PORT}
  gitlab_shell:
    ssh_port: ${CUSTOM_SSH_PORT}
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
    host: ${CUSTOM_HOSTNAME}
    port: ${CUSTOM_REGISTRY_PORT}
    api_url: http://registry:5000/ # internal address to the registry, will be used by GitLab to directly communicate with API
    key: /home/git/registry-auth.key
    issuer: gitlab-issuer
    # path: shared/registry
  monitoring:
    ip_whitelist:
      - 0.0.0.0/0
    sidekiq_exporter:
      enabled: true
      address: 0.0.0.0
      port: 3807
  repositories:
    storages:
      default:
        path: /data/repositories/
        gitaly_address: tcp://gitaly:9999
  gitlab_ci:
    builds_path: /data/shared/builds
  pages:
    path: /data/shared/pages
  webpack:
    dev_server:
      enabled: ${USE_WEBPACK_DEV:-false}
      host: webpack
      port: 3808
  artifacts:
    enabled: true
    path: /data/shared/artifacts
    object_store:
      enabled: false # not yet supported natively
      remote_directory: artifacts-bucket # The bucket name
      proxy_download: true # this is required as we cannot connect from external to minio
      connection:
        provider: AWS
        endpoint: 'http://minio:9000'
        path_style: true # this is required as only DNS name exposed is minio
        aws_access_key_id: TEST_KEY
        aws_secret_access_key: TEST_SECRET
  lfs:
    enabled: true
    storage_path: /data/shared/lfs
    object_store:
      enabled: true
      remote_directory: lfs-bucket # The bucket name
      proxy_download: true # this is required as we cannot connect from external to minio
      connection:
        provider: AWS
        endpoint: 'http://minio:9000'
        path_style: true # this is required as only DNS name exposed is minio
        aws_access_key_id: TEST_KEY
        aws_secret_access_key: TEST_SECRET
  uploads:
    storage_path: /home/git/gitlab/public/
    object_store:
      enabled: true
      remote_directory: uploads-bucket # The bucket name
      proxy_download: true # this is required as we cannot connect from external to minio
      connection:
        provider: AWS
        endpoint: 'http://minio:9000'
        path_style: true # this is required as only DNS name exposed is minio
        aws_access_key_id: TEST_KEY
        aws_secret_access_key: TEST_SECRET

development: *production
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
production:
  db_key_base: 9a138cf90aa854ba65b50a5e2e76b2acfb9dfd22d1df5ccb9e1ff5a6f9657e2c

development:
  db_key_base: 9a138cf90aa854ba65b50a5e2e76b2acfb9dfd22d1df5ccb9e1ff5a6f9657e2c

test:
  db_key_base: 9a138cf90aa854ba65b50a5e2e76b2acfb9dfd22d1df5ccb9e1ff5a6f9657e2c
EOF
fi

/scripts/helpers/merge-yaml.rb /dev/stdin /home/git/gck-custom.yml:resque.yml > config/resque.yml <<EOF
production: &production
  url: redis://redis:6379
development: *production
test: *production
EOF

/scripts/helpers/merge-yaml.rb /dev/stdin /home/git/gck-custom.yml:database.yml > config/database.yml <<EOF
production: &production
  adapter: postgresql
  encoding: unicode
  database: gitlabhq_development
  pool: 5
  username: postgres
  password: password
  host: postgres

development:
  <<: *production

staging:
  <<: *production
  database: gitlabhq_staging

test:
  <<: *production
  database: gitlabhq_test_<%= File.exist?('ee/app/models/license.rb') && !%w[true 1].include?(ENV['FOSS_ONLY'].to_s) ? 'ee' : 'ce' %>
EOF

cp -u config/initializers/rack_attack.rb.example config/initializers/rack_attack.rb

mkdir -p public/uploads/
