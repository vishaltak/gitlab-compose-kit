#!/usr/bin/env bash

sudo chown git /data
sudo chown git /data/{cache,repositories,shared}

mkdir -p /data/shared/{artifacts,uploads,pages,builds,lfs}

exit 0
