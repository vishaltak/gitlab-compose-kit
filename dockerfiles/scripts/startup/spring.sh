#!/bin/bash

_term() { 
  echo "Caught SIGTERM signal! Sending kill to all processes"
  kill -TERM -1
}

trap _term SIGTERM

cat
