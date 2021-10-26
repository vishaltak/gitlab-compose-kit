#!/bin/bash

# Workarounds the presence of `GIT_VERSION` which has side effects on Gitaly
# https://gitlab.com/gitlab-org/gitlab-compose-kit/-/issues/59

unset GIT_VERSION
