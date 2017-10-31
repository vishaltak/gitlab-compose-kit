FROM ubuntu:artful

RUN apt-get update -y && \
    apt-get install -y software-properties-common python-software-properties \
      git postgresql postgresql-contrib libpq-dev redis-server libicu-dev cmake \
      build-essential nodejs npm libre2-dev libkrb5-dev golang ed pkg-config \
      ruby-dev ruby-bundler sudo libsqlite3-dev

RUN npm install phantomjs-prebuilt@2.1.12 yarn -g --unsafe-perm
RUN gem install bundler

RUN apt-get install -y libmysqlclient-dev

ARG UID
ARG GID
ARG HOME

RUN groupadd -g "$GID" git
RUN useradd -g "$GID" -u "$UID" -m -d "/home/git" git

USER git

VOLUME ["/home/git"]

# install things globally, for great justice
# and don't create ".bundle" in all our apps
ENV HOME=/home/git \
    GEM_HOME=/home/git/bundle \
    GOPATH=/home/git/go

ENV BUNDLE_PATH="$GEM_HOME" \
    BUNDLE_BIN="$GEM_HOME/bin" \
    BUNDLE_SILENCE_ROOT_WARNING=1 \
    BUNDLE_APP_CONFIG="$GEM_HOME"

ENV PATH="$BUNDLE_BIN:$GOPATH/bin:$PATH"

ADD /scripts /scripts
