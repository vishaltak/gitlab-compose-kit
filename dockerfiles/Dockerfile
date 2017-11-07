FROM ubuntu:artful

RUN apt-get update -y && \
    apt-get install -y software-properties-common python-software-properties \
      git postgresql postgresql-contrib libpq-dev redis-server libicu-dev cmake \
      build-essential nodejs npm libre2-dev libkrb5-dev golang ed pkg-config \
      ruby-dev ruby-bundler sudo libsqlite3-dev libmysqlclient-dev openssh-server \
      libfontconfig1 chromium-chromedriver

RUN npm install phantomjs-prebuilt@2.1.12 yarn -g --unsafe-perm
RUN gem install bundler
RUN ln -s /usr/lib/chromium-browser/chromedriver /usr/bin/chromedriver

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
    GEM_HOME=/data/cache/bundle \
    GOPATH=/data/cache/go \
    npm_config_prefix=/data/cache/node_modules \
    YARN_CACHE_FOLDER=/data/cache/yarn

ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"

ENV PATH="$BUNDLE_BIN:$GOPATH/bin:$PATH"

ADD /scripts /scripts
