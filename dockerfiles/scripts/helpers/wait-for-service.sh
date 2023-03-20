#!/bin/bash

set -eo pipefail

if [[ $# -ne 3 ]]; then
  echo "usage: $0 tcp <hostname> <port>"
  echo "usage: $0 file <name> <file>"
  exit 1
fi

max_attempts=600 # around 10 minutes

echo -n "Waiting for $2"
for i in $(seq 1 $max_attempts); do
  case "$1" in
    tcp)
      if timeout 1 bash -c "</dev/tcp/$2/$3" 2>/dev/null; then
        echo " Done"
        exit 0
      fi
      ;;
    
    file)
      if [[ -f "$3" ]]; then
        echo " Done"
        exit 0
      fi
      ;;

    *)
      echo " What is the '$1'?"
      exit 1
      ;;
  esac

  echo -n "."
  sleep 1s
done

echo "'$2' failed to start after $max_attempts attempts"
exit 1
