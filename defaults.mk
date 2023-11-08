export BASE_IMAGE_REPOSITORY ?= registry.gitlab.com/gitlab-org/gitlab-build-images/debian-bullseye-ruby-3.1.patched-golang-1.20-rust-1.65-node-18.16-postgresql-14
export BASE_IMAGE_TAG ?= rubygems-3.4-git-2.36-lfs-2.9-chrome-109-yarn-1.22-graphicsmagick-1.3.36
export BASE_IMAGE ?= ${BASE_IMAGE_REPOSITORY}:${BASE_IMAGE_TAG}

export USE_WEB_SERVER ?= puma
export USE_TRACING ?=
export USE_WEBPACK_DEV ?= false
export USE_CABLE_SERVER ?= true
export ENABLE_SPRING ?= 1
export RAILS_ENV ?= development
export FOSS_ONLY ?=
export ADDITIONAL_DEPS ?=

export CUSTOM_WEB_PORT ?= 3000
export CUSTOM_SSH_PORT ?= 2222
export CUSTOM_REGISTRY_PORT ?= 5000
export CUSTOM_WEBPACK_PORT ?= 3808
export CUSTOM_MINIO_CONSOLE_PORT ?= 9001
export CUSTOM_WEB_CONFIG ?=
export CUSTOM_REDIS_ALT_STORE ?=
export CUSTOM_ENV ?=
