export GCK_HOME=$(CURDIR)

export COMPOSE_PROJECT_NAME ?= $(notdir $(CURDIR))
export COMPOSE_KIT_REVISION ?= $(shell git -C . rev-parse HEAD 2>/dev/null || echo "unknown")
export COMPOSE_HTTP_TIMEOUT ?= 3600

export GITLAB_RAILS_REVISION ?= $(shell git -C gitlab-rails rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_SHELL_REVISION ?= $(shell git -C gitlab-shell rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_WORKHORSE_REVISION ?= $(shell git -C gitlab-workhorse rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_GITALY_REVISION ?= $(shell git -C gitlab-gitaly rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_PAGES_REVISION ?= $(shell git -C gitlab-pages rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_METRICS_EXPORTER_REVISION ?= $(shell git -C gitlab-metrics-exporter rev-parse HEAD 2>/dev/null || echo "unknown")
export GITLAB_SPRING_REVISION ?= $(shell git -C gitlab-rails rev-parse --short HEAD || echo "unknown")

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
ifeq (,$(wildcard gck.env))
$(shell touch gck.env)
endif

ifeq (,$(wildcard gck.yml))
$(shell touch gck.yml)
endif

# Include custom env and export all
export
export DO_NOT_EXPORT_VARIABLES := $(.VARIABLES)
include defaults.mk
include gck.env
export

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
