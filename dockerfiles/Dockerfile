ARG BASE_IMAGE
FROM ${BASE_IMAGE}

RUN [ -n "$RUBY_VERSION" ] || ( echo "*** RUBY_VERSION is required to be defined by base image"; exit 1 )

ARG ADDITIONAL_DEPS
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y \
        software-properties-common curl \
        build-essential pkg-config cmake \
        sudo openssh-server redis-tools \
        moreutils smem strace lsof gdb sysstat \
        ccache docker.io \
        firefox-esr \
        apache2-utils inetutils-ping dnsutils tcpdump net-tools \
        nano vim \
        exiftool \
        $ADDITIONAL_DEPS

# TODO: Make arm64 compatible
RUN curl -L https://github.com/mozilla/geckodriver/releases/download/v0.30.0/geckodriver-v0.30.0-linux64.tar.gz | tar -zxC /usr/local/bin

RUN cd /tmp && \
    wget https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_$(dpkg --print-architecture).deb  && \
    dpkg -i dumb-init_*.deb && \
    rm -f dumb-init_*.deb

ARG UID
ARG GID

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i -e \
    's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=\(ALL\) NOPASSWD:ALL/g' \
    /etc/sudoers

RUN groupadd -g "$GID" git || groupadd git || true
RUN useradd -g git -G sudo -u "$UID" -m -d "/home/git" git
RUN usermod -p '*' git

# allow Git user to modify directories in /usr/local
RUN chown git:git $(find /usr/local -type d)

# For best performance require that Ruby is compiled with jemalloc2
RUN ldd $(which ruby) | grep libjemalloc.so.2

USER git

VOLUME ["/home/git", "/data/cache", "/data/repositories", "/data/shared"]

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

ENV PATH="$GEM_HOME/bin:$GOPATH/bin:$GOROOT/bin:/scripts/ccache:$PATH"

ADD /scripts /scripts
