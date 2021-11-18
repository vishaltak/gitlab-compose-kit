ARG BASE_IMAGE=registry.gitlab.com/gitlab-org/gitlab-build-images:ruby-2.7.patched-golang-1.16-git-2.31-lfs-2.9-chrome-89-node-14.15-yarn-1.22-postgresql-12-graphicsmagick-1.3.36
FROM ${BASE_IMAGE}

RUN [ -n "$RUBY_VERSION" ] || ( echo "*** RUBY_VERSION is required to be defined by base image"; exit 1 )

ARG ADDITIONAL_DEPS
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y \
        software-properties-common curl \
        build-essential pkg-config cmake \
        sudo openssh-server redis-tools libjemalloc2 \
        moreutils smem strace lsof \
        ccache \
        $ADDITIONAL_DEPS

RUN apt-get install -y firefox-esr && \
    curl -L https://github.com/mozilla/geckodriver/releases/download/v0.30.0/geckodriver-v0.30.0-linux64.tar.gz | tar -zxC /usr/local/bin

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod +x /usr/local/bin/dumb-init

ARG UID
ARG GID

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i -e \
    's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=\(ALL\) NOPASSWD:ALL/g' \
    /etc/sudoers

RUN groupadd -g "$GID" git || true
RUN useradd -g "$GID" -G sudo -u "$UID" -m -d "/home/git" git
RUN usermod -p '*' git

# allow Git user to modify directories in /usr/local
RUN chown git:git $(find /usr/local -type d)

USER git

VOLUME ["/home/git", "/data/cache"]

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV HOME=/home/git \
    GEM_HOME=/data/cache/bundle-${RUBY_VERSION} \
    GOPATH=/data/cache/go \
    GOROOT=/usr/local/go \
    GOCACHE=/data/cache/go-build \
    npm_config_prefix=/data/cache/node_modules \
    YARN_CACHE_FOLDER=/data/cache/yarn \
    WEBPACK_CACHE_PATH=/data/cache/webpack \
    BOOTSNAP_CACHE_PATH=/data/cache/bootsnap \
    CCACHE_DIR=/data/cache/ccache

# Use jemalloc2
# - As our production application uses it as well
# - MALLOC_CONF is a new thing that makes a jemalloc2
#   free memory as soon as possible
ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 \
    MALLOC_CONF=dirty_decay_ms:0,muzzy_decay_ms:0

ENV PATH="$GOPATH/bin:$GOROOT/bin:/scripts/ccache:$PATH"

ADD /scripts /scripts
