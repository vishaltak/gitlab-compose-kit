ARG BASE_IMAGE=registry.gitlab.com/gitlab-org/gitlab-build-images:ruby-2.7.2.patched-golang-1.14-git-2.29-lfs-2.9-chrome-87-node-14.15-yarn-1.22-postgresql-12-graphicsmagick-1.3.34
FROM ${BASE_IMAGE}

RUN [ -n "$RUBY_VERSION" ] || ( echo "*** RUBY_VERSION is required to be defined by base image"; exit 1 )

ARG ADDITIONAL_DEPS
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y \
        software-properties-common curl \
        build-essential pkg-config cmake \
        sudo openssh-server redis-tools \
        moreutils smem strace lsof \
        $ADDITIONAL_DEPS

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
    BOOTSNAP_CACHE_PATH=/data/cache/bootsnap

ENV BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME" \
    BUNDLE_WITHOUT=production \
    BUNDLE_JOBS=6 \
    BUNDLE_USER_HOME="$GEM_HOME/user-home"

ENV PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

ADD /scripts /scripts
