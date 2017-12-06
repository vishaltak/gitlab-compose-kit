export USE_RAILS_SERVER ?=
export CHROME_HEADLESS ?= false
export DISPLAY ?=

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
