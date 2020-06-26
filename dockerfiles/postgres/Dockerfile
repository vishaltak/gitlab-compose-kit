FROM postgres:9-alpine AS pg96

FROM postgres:11-alpine AS pg11

# pg_upgrade requires binaries from 9.6
COPY --from=pg96 / /pg96
ADD initdb.d/ /docker-entrypoint-initdb.d/

ENV PGROOT="$PGDATA"
ENV PGDATA="$PGROOT/$PG_MAJOR"
