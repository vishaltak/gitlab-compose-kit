export USE_RAILS_SERVER ?= 1
export USE_RAILS5 ?=
export CHROME_HEADLESS ?= false
export DISPLAY ?=
export ENABLE_SPRING ?= 1

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
