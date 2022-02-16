#!/bin/bash

# Use jemalloc2
# - As our production application uses it as well
export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2
