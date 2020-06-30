FROM postgres:9-alpine AS pg96

FROM postgres:11-alpine AS pg11

# pg_upgrade requires binaries from 9.6
COPY --from=pg96 / /postgres/9.6
ADD initdb.d/ /docker-entrypoint-initdb.d/

# Each version requires that chroot of that image
# is part of `/postgres/<version>`
# Update `bats/pg_upgrade.bats` with relevant test
ENV UPGRADEABLE_PGVERSIONS="9.6"

ENV PGROOT="$PGDATA"
ENV PGDATA="$PGROOT/$PG_MAJOR"
