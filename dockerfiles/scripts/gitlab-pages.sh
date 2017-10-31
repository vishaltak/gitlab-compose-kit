#!/bin/bash

set -xe

cd /home/git/go/src/gitlab.com/gitlab-org/gitlab-pages
go build

exec ./gitlab-pages -artifacts-server="http://workhorse:8181/api/v4" \
  -listen-proxy=0.0.0.0:8989 \
  -pages-root=/home/git/gitlab/shared/pages \
  -pages-status=/@status
