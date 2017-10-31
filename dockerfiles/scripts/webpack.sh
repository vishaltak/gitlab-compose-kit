#!/bin/bash

set -xe

cd /home/git/gitlab
yarn install
npm run webpack
