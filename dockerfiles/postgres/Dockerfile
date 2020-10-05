FROM postgres:9.6-alpine AS pg96

FROM postgres:11-alpine AS pg11

FROM postgres:12-alpine AS pg12

# pg_upgrade requires binaries from 9.6
COPY --from=pg96 / /postgres/9.6

# pg_upgrade requires binaries from 11
COPY --from=pg11 / /postgres/11

ADD initdb.d/ /docker-entrypoint-initdb.d/

# Each version requires that chroot of that image
# is part of `/postgres/<version>`
# Update `bats/pg_upgrade.bats` with relevant test
ENV UPGRADEABLE_PGVERSIONS="9.6 11"

ENV PGROOT="$PGDATA"
ENV PGDATA="$PGROOT/$PG_MAJOR"
