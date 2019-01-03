FROM ubuntu:bionic

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y software-properties-common \
      git postgresql postgresql-contrib libpq-dev redis-server libicu-dev cmake \
      build-essential nodejs npm libre2-dev libkrb5-dev golang ed pkg-config \
      sudo libsqlite3-dev libmysqlclient-dev openssh-server \
      libfontconfig1 chromium-chromedriver
RUN ln -s /usr/lib/chromium-browser/chromedriver /usr/bin/chromedriver

RUN apt-add-repository ppa:brightbox/ruby-ng && \
    apt-get update -y && \
    apt-get install -y ruby2.5 ruby2.5-dev && \
    gem update --system && \
    gem install bundler

RUN apt-add-repository "deb http://pl.archive.ubuntu.com/ubuntu/ bionic main restricted universe" && \
    apt-get update -y && \
    apt-get install -y nodejs npm golang && \
    npm install phantomjs-prebuilt@2.1.12 yarn -g --unsafe-perm

RUN wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64 && \
    chmod +x /usr/local/bin/dumb-init

ARG UID
ARG GID

# Enable passwordless sudo for users under the "sudo" group
RUN sed -i -e \
    's/%sudo\s\+ALL=(ALL\(:ALL\)\?)\s\+ALL/%sudo ALL=NOPASSWD:ALL/g' \
    /etc/sudoers

RUN groupadd -g "$GID" git || true
RUN useradd -g "$GID" -G sudo -u "$UID" -m -d "/home/git" git
RUN usermod -p '*' git

USER git

VOLUME ["/home/git", "/data/cache"]

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV HOME=/home/git \
    GEM_HOME=/data/cache/bundle-2.5 \
    GOPATH=/data/cache/go \
    GOCACHE=/data/cache/go-build \
    npm_config_prefix=/data/cache/node_modules \
    YARN_CACHE_FOLDER=/data/cache/yarn \
    WEBPACK_CACHE_PATH=/data/cache/webpack \
    BOOTSNAP_CACHE_PATH=/data/cache/bootsnap

ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME" \
    BUNDLE_WITHOUT=production \
    BUNDLE_JOBS=6 \
    BUNDLE_IGNORE_CONFIG=1 \
    BUNDLE_USER_HOME="/data/cache/bundle-user-home"

ENV PATH="$GOPATH/bin:$PATH"

ADD /scripts /scripts
