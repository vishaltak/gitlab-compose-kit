#!/usr/bin/env bats

##-------
## TESTS
##-------

@test "Migrate PostgreSQL 12 to 14" {
  migrate_from_pg_major "12"
}

@test "Migrate PostgreSQL 13 to 14" {
  migrate_from_pg_major "13"
}

##-------------
## ENVIRONMENT
##-------------

setup() {
  IMAGE_ID=$(docker build -q dockerfiles/postgres)
  DATA_ID=$(docker volume create)
}

teardown() {
  [[ -n "$ID" ]] && docker logs "$ID"
  [[ -n "$ID" ]] && docker rm -f "$ID"
  [[ -n "$IMAGE_ID" ]] && docker image rm -f "$IMAGE_ID"
  [[ -n "$DATA_ID" ]] && docker volume rm -f "$DATA_ID"
}

##---------
## HELPERS
##---------

migrate_from_pg_major() {
  let pg_major=$1

  create_db_container "postgres:${pg_major}-alpine"
  psql -c "CREATE DATABASE my_database"
  psql my_database -c "SELECT 1"
  drop_db_container

  # Start latest and expect data to be migrated
  create_db_container "$IMAGE_ID"
  psql my_database -c "SELECT 1"
  drop_db_container
}

psql() {
  docker exec -i "$ID" psql -U postgres -h 127.0.0.1 "$@"
}

create_db_container() {
  ID=$(docker run -v "$DATA_ID:/var/lib/postgresql/data" -e POSTGRES_PASSWORD=password -d "$@")
  wait_for 30 psql -c "SELECT 1"
}

drop_db_container() {
  docker logs "$ID"
  docker stop "$ID"
  docker rm "$ID"
  ID=""
}

wait_for() {
  local TIMEOUT="$1"
  shift

  for i in $(seq $TIMEOUT); do
    "$@" && return 0
    sleep 1s
  done

  return 1
}
