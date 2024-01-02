#!/usr/bin/env bash

# Use jemalloc2
# - As our production application uses it as well
export LD_PRELOAD=/usr/lib/$(dpkg-architecture -qDEB_TARGET_GNU_TYPE)/libjemalloc.so.2
