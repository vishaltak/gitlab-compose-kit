#!/usr/bin/env bash

_term() { 
  echo "Caught SIGTERM signal! Sending kill to all processes"
  kill -TERM -1
}

trap _term SIGTERM

is_used() {
  # The ppid 0 are processes created by `run` or `exec` of `docker-compose`
  # The `run` uses 1 process, this is why it has to be `-gt 1`
  local cnt=$(pgrep -P 0 | wc -l)
  echo "Used by $cnt processes..."
  [[ $cnt -gt 1 ]]
}

# Call the given method until it succeeds
retry() {
  for i in 1 2 3 4 5 6 7 8 9 10; do
    if eval "$@"; then
      return 0
    fi

    sleep 5s
    echo "Retrying $i..."
  done

  return 1
}

while retry is_used; do
  sleep 60s
done

echo 'No more `docker-compose exec` running. Exiting'
