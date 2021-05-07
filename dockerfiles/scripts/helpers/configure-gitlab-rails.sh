#!/bin/bash

set -xeo pipefail

cd /home/git/gitlab

echo gitlab_shell_secret | sponge /home/git/shell-secret

if ! bundle install --quiet --local; then
  bundle install
fi

git config --global core.autocrlf input
git config --global gc.auto 0
git config --global repack.writeBitmaps true

echo "$CUSTOM_CONFIG" | sponge /home/git/gck-custom.yml

/scripts/helpers/merge-yaml.rb config/gitlab.yml.example /dev/stdin /home/git/gck-custom.yml:gitlab.yml <<EOF | sponge config/gitlab.yml
production: &production
  gitlab:
    host: ${CUSTOM_HOSTNAME}
    port: ${CUSTOM_WEB_PORT}
    content_security_policy:
      directives:
        connect_src: "'self' http://${CUSTOM_HOSTNAME}:* ws://${CUSTOM_HOSTNAME}:* wss://${CUSTOM_HOSTNAME}:*"
        script_src: "'self' 'unsafe-eval' http://${CUSTOM_HOSTNAME}:* https://www.google.com/recaptcha/ https://www.recaptcha.net/ https://www.gstatic.com/recaptcha/ https://apis.google.com"
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
    path: /data/shared/pages
    object_store:
      enabled: true
      remote_directory: pages-bucket # The bucket name
      proxy_download: true # this is required as we cannot connect from external to minio
      connection:
        provider: AWS
        endpoint: 'http://minio:9000'
        path_style: true # this is required as only DNS name exposed is minio
        aws_access_key_id: TEST_KEY
        aws_secret_access_key: TEST_SECRET
    local_store:
      enabled: true
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
  webpack:
    dev_server:
      enabled: ${USE_WEBPACK_DEV:-false}
      host: webpack
      port: ${CUSTOM_WEBPACK_PORT}
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
  prometheus:
    enable: true
    listen_address: prometheus:9090

development: *production
EOF

if [[ ! -e /home/git/registry-auth.crt ]]; then
  openssl req -newkey rsa:2048 -x509 -nodes -days 3560 \
    -subj "/CN=gitlab.development.kit" \
    -out /home/git/registry-auth.crt -keyout /home/git/registry-auth.key
fi

# Workhorse secret has to be 32 bytes
echo -n 12345678901234567890123456789012 | base64 | sponge /home/git/workhorse-secret

if [[ ! -e config/secrets.yml ]]; then
  sponge config/secrets.yml <<EOF
production:
  db_key_base: 9a138cf90aa854ba65b50a5e2e76b2acfb9dfd22d1df5ccb9e1ff5a6f9657e2c

development:
  db_key_base: 9a138cf90aa854ba65b50a5e2e76b2acfb9dfd22d1df5ccb9e1ff5a6f9657e2c

test:
  db_key_base: 9a138cf90aa854ba65b50a5e2e76b2acfb9dfd22d1df5ccb9e1ff5a6f9657e2c
EOF
fi

/scripts/helpers/merge-yaml.rb /dev/stdin /home/git/gck-custom.yml:resque.yml <<EOF | sponge config/resque.yml
production: &production
  url: redis://redis:6379
development: *production
test: *production
EOF

/scripts/helpers/merge-yaml.rb /dev/stdin /home/git/gck-custom.yml:database.yml <<EOF | sponge config/database.yml
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

/scripts/helpers/merge-yaml.rb /dev/stdin /home/git/gck-custom.yml:cable.yml <<EOF | sponge config/cable.yml
production: &production
  adapter: redis
  url: redis://redis:6379
  channel_prefix: gitlab_production
development:
  <<: *production
  channel_prefix: gitlab_development
test:
  <<: *production
  channel_prefix: gitlab_test
EOF

mkdir -p public/uploads/
