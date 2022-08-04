export GCK_HOME=$(CURDIR)

export BASE_IMAGE_REPOSITORY ?= registry.gitlab.com/gitlab-org/gitlab-build-images/debian-bullseye-ruby-2.7.patched-golang-1.17-node-16.14-postgresql-12
export BASE_IMAGE_TAG ?= rubygems-3.2-git-2.36-lfs-2.9-chrome-103-yarn-1.22-graphicsmagick-1.3.36
export USE_WEB_SERVER ?= puma
export USE_TRACING ?=
export USE_WEBPACK_DEV ?= false
export FORCE_WEBPACK_COMPILE ?= false
export USE_CABLE_SERVER ?= true
export CHROME_HEADLESS ?=
export WEBDRIVER_HEADLESS ?=
export DISPLAY ?=
export ENABLE_SPRING ?= 1
export COMPOSE_HTTP_TIMEOUT ?= 3600
export RAILS_ENV ?= development
export FOSS_ONLY ?=
export FORCE_BIND_MOUNT ?=
export ADDITIONAL_DEPS ?= 

export CUSTOM_WEB_PORT ?= 3000
export CUSTOM_SSH_PORT ?= 2222
export CUSTOM_REGISTRY_PORT ?= 5000
export CUSTOM_WEBPACK_PORT ?= 3808
export CUSTOM_MINIO_CONSOLE_PORT ?= 9001
export CUSTOM_WEB_CONFIG ?=
export CUSTOM_REDIS_ALT_STORE ?=

export SIDEKIQ_WORKERS ?=
export SIDEKIQ_QUEUES ?=

export GITLAB_RAILS_REVISION ?= $(shell git -C gitlab-rails rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_SHELL_REVISION ?= $(shell git -C gitlab-shell rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_WORKHORSE_REVISION ?= $(shell git -C gitlab-workhorse rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_GITALY_REVISION ?= $(shell git -C gitlab-gitaly rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_PAGES_REVISION ?= $(shell git -C gitlab-pages rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_METRICS_EXPORTER_REVISION ?= $(shell git -C gitlab-metrics-exporter rev-parse HEAD 2>/dev/null || echo "unknown")
export COMPOSE_KIT_REVISION ?= $(shell git -C . rev-parse HEAD 2>/dev/null || echo "unknown")

# If FORCE_BIND_MOUNT is set
# do mount using bind-mount
ifeq (Darwin,$(shell uname -s)$(FORCE_BIND_MOUNT))
export SRC_MOUNT_TYPE ?= nfs
export SRC_MOUNT_OPTS ?= addr=host.docker.internal,rw,nolock,hard,intr,nfsvers=3
export SRC_MOUNT_PATH ?= \:$(CURDIR)
else
export SRC_MOUNT_TYPE ?=
export SRC_MOUNT_OPTS ?= bind
export SRC_MOUNT_PATH ?= $(CURDIR)
endif

# Deprecations
ifneq (,$(wildcard .env))
$(error "`.env` file is not supported by gck, use `gck.env` file instead")
endif

ifneq (,$(wildcard gitlab.yml))
$(error "`gitlab.yml` file is not supported, use `gck.yml` file instead")
endif

# Include configs
ifneq (,$(wildcard gck.env))
include gck.env
endif

ifeq (,$(wildcard gck.yml))
$(shell touch gck.yml)
endif

# Define if services should be enabled by default depending on configuration
ifneq (,$(CUSTOM_REDIS_ALT_STORE))
export ENABLE_REDIS_ALT_STORE = 1
else
export ENABLE_REDIS_ALT_STORE = 0
endif

all: help

help:
	@echo 'Available targets:'
	@sed -n 's/^.PHONY: \(.*\)$$/- \1/p' Makefile*

include Makefile.dc.mk
include Makefile.repos.mk
include Makefile.deps.mk
include Makefile.env.mk
include Makefile.control.mk
include Makefile.sync.mk
