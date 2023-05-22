FROM postgres:12-alpine AS pg12
FROM postgres:13-alpine AS pg13

# pg_upgrade requires binaries from 12
COPY --from=pg12 / /postgres/12

ADD . /

# Each version requires that chroot of that image
# is part of `/postgres/<version>`
# Update `bats/pg_upgrade.bats` with relevant test
ENV UPGRADEABLE_PGVERSIONS="12"

ENV PGROOT="$PGDATA"
ENV PGDATA="$PGROOT/$PG_MAJOR"

CMD ["postgres", "--hba_file=/config/pg_hba.conf"]
