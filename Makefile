export GCK_HOME=$(CURDIR)

export USE_WEB_SERVER ?= puma
export USE_RAILS ?= rails5
export USE_TRACING ?=
export USE_WEBPACK_DEV ?= false
export CHROME_HEADLESS ?= false
export DISPLAY ?=
export ENABLE_SPRING ?= 1
export COMPOSE_HTTP_TIMEOUT ?= 3600
export RAILS_ENV ?= development
export FOSS_ONLY ?=
export FORCE_BIND_MOUNT ?=

export CUSTOM_WEB_PORT ?= 3000
export CUSTOM_SSH_PORT ?= 2222
export CUSTOM_REGISTRY_PORT ?= 5000
export CUSTOM_WEB_CONFIG ?=

export GITLAB_RAILS_REVISION ?= $(shell git -C gitlab-rails describe 2>/dev/null || echo "unknown")
export GITLAB_SHELL_REVISION ?= $(shell git -C gitlab-shell describe 2>/dev/null || echo "unknown")
export GITLAB_WORKHORSE_REVISION ?= $(shell git -C gitlab-workhorse describe 2>/dev/null || echo "unknown")
export GITLAB_GITALY_REVISION ?= $(shell git -C gitlab-gitaly describe 2>/dev/null || echo "unknown")
export GITLAB_PAGES_REVISION ?= $(shell git -C gitlab-pages describe 2>/dev/null || echo "unknown")
export COMPOSE_KIT_REVISION ?= $(shell git -C . describe 2>/dev/null || echo "unknown")

# If SSH_TARGET_HOST or FORCE_BIND_MOUNT is set
# do mount using bind-mount
ifeq (Darwin,$(shell uname -s)$(SSH_TARGET_HOST)$(FORCE_BIND_MOUNT))
export SRC_MOUNT_TYPE ?= nfs
export SRC_MOUNT_OPTS ?= addr=host.docker.internal,rw,nolock,hard,intr,nfsvers=3
export SRC_MOUNT_PATH ?= \:$(CURDIR)
else
export SRC_MOUNT_TYPE ?=
export SRC_MOUNT_OPTS ?= bind
export SRC_MOUNT_PATH ?= $(CURDIR)
endif

ifneq (,$(wildcard .env))
include .env
endif

ifeq (,$(wildcard gck.yml))
$(shell touch gck.yml)
endif

all: help

help:
	@echo 'Available targets:'
	@sed -n 's/^.PHONY: \(.*\)$$/- \1/p' Makefile*

include Makefile.repos.mk
include Makefile.deps.mk
include Makefile.env.mk
include Makefile.control.mk
include Makefile.sync.mk
