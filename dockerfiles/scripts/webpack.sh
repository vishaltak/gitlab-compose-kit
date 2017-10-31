#!/bin/bash

set -xe

cd /home/git/gitlab
yarn install
exec yarn dev-server
