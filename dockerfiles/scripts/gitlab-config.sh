#!/bin/bash

set -xe

cd /home/git/gitlab
bundle install --without production mysql sqlite3
