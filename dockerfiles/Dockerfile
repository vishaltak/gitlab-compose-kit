FROM ubuntu:bionic

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update -y && \
    apt-get install -y software-properties-common curl \
      libpq-dev redis-server libicu-dev libssl-dev cmake \
      build-essential libre2-dev libkrb5-dev ed pkg-config \
      sudo libsqlite3-dev openssh-server \
      libfontconfig1 chromium-chromedriver unzip \
      moreutils smem strace lsof \
      exiftool graphicsmagick # Required by workhorse to process images 

RUN if [ ! -f /usr/bin/chromedriver ]; then ln -s /usr/lib/chromium-browser/chromedriver /usr/bin/chromedriver; fi

RUN apt-add-repository ppa:git-core/ppa && \
    apt-get update -y && \
    apt-get install -y git

ENV RUBY_VERSION=2.7

# Workarounds:
# 1. `dpkg-divert` is a fix for `warning: constant Gem::ConfigMap is deprecated`
#    https://github.com/rubygems/rubygems/issues/3068
#    An alternative is to use `DEBIAN_DISABLE_RUBYGEMS_INTEGRATION=true`,
#    but Gitaly does selectively pass env variables to `bundle exec`:
#    https://gitlab.com/gitlab-org/gitaly/blob/1fdfa49c8a43559a94ea1ee1960356261bd8d092/internal/gitaly/linguist/linguist.go#L23
# 2. `ppa:ayufan/ruby-ppa` is to add `ruby2.7` since `ppa:brightbox/ruby-ng`
#    does not have it yet

RUN apt-add-repository ppa:brightbox/ruby-ng && \
    apt-add-repository ppa:ayufan/ruby-ppa && \
    apt-get update -y && \
    apt-get install -y ruby${RUBY_VERSION} ruby${RUBY_VERSION}-dev && \
    dpkg-divert --add --rename --divert /usr/lib/ruby/vendor_ruby/rubygems/defaults/operating_system.rb.bak /usr/lib/ruby/vendor_ruby/rubygems/defaults/operating_system.rb && \
    gem install bundler -v "~>2.0" && \
    gem install bundler -v "~>1.0"

RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - && \
    apt-add-repository "deb https://deb.nodesource.com/node_12.x bionic main" && \
    apt-get update -y && \
    apt-get install -y nodejs && \
    npm install yarn -g --unsafe-perm

RUN wget -q -O - https://dl.google.com/go/go1.13.linux-amd64.tar.gz | \
    tar -zxC /usr/local

RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-add-repository "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" && \
    apt-get update -y && \
    apt-get install -y postgresql-12 postgresql-contrib-12

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
