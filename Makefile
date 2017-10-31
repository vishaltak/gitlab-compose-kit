export HOST = $(shell hostname -I | cut -d' ' -f1 || echo localhost)

all: help

help:
	@echo 'Available targets:'
	@sed -n 's/^.PHONY: \(.*\)$$/- \1/p' Makefile*

include Makefile.deps.mk
include Makefile.env.mk
include Makefile.control.mk
