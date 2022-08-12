#!/bin/bash

sudo chown git /data
sudo chown git /data/cache
sudo chown git /data/repositories
sudo chown git /data/shared

mkdir /data/shared/{artifacts,uploads,pages,builds,lfs}
sudo chown git /data/shared/*

exit 0
