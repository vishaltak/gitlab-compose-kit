export USE_RAILS_SERVER ?= 1
export USE_RAILS5 ?=
export USE_DB ?= postgres
export USE_WEBPACK_DEV ?= true
export CHROME_HEADLESS ?= false
export DISPLAY ?=
export ENABLE_SPRING ?= 1
export COMPOSE_HTTP_TIMEOUT ?= 3600

export CUSTOM_WEB_PORT ?= 3000
export CUSTOM_SSH_PORT ?= 2222
export CUSTOM_REGISTRY_PORT ?= 5000

export GITLAB_RAILS_REVISION ?= $(shell git -C gitlab-rails describe 2>/dev/null || echo "unknown")
export GITLAB_SHELL_REVISION ?= $(shell git -C gitlab-shell describe 2>/dev/null || echo "unknown")
export GITLAB_WORKHORSE_REVISION ?= $(shell git -C gitlab-workhorse describe 2>/dev/null || echo "unknown")
export GITLAB_GITALY_REVISION ?= $(shell git -C gitlab-gitaly describe 2>/dev/null || echo "unknown")
export GITLAB_PAGES_REVISION ?= $(shell git -C gitlab-pages describe 2>/dev/null || echo "unknown")
export COMPOSE_KIT_REVISION ?= $(shell git -C . describe 2>/dev/null || echo "unknown")

ifeq (,$(wildcard gitlab.yml))
$(shell touch gitlab.yml)
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
