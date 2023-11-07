FROM postgres:12-alpine AS pg12
FROM postgres:13-alpine AS pg13
FROM postgres:14-alpine AS pg14

# pg_upgrade requires binaries from previous version
COPY --from=pg12 / /postgres/12
COPY --from=pg13 / /postgres/13

ADD . /

# Each version requires that chroot of that image
# is part of `/postgres/<version>`
# Update `bats/pg_upgrade.bats` with relevant test
ENV UPGRADEABLE_PGVERSIONS="12 13"

ENV PGROOT="$PGDATA"
ENV PGDATA="$PGROOT/$PG_MAJOR"

CMD ["postgres", "--hba_file=/config/pg_hba.conf"]
