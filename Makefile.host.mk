ifeq ($(OS),Windows_NT)
$(error Windows is not yet supported)
else
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
HOST ?= $(shell hostname -I | cut -d' ' -f1)
endif
ifeq ($(UNAME_S),Darwin)
HOST ?= $(shell ipconfig getifaddr en0 || ipconfig getifaddr en1 || ipconfig getifaddr en2)
endif
endif

ifeq (,$(HOST))
$(error Could not detect IP address. Consider setting this as an environment variable: export HOST=<my-ip-address>)
endif

export HOST
