FROM ubuntu:16.04

RUN apt-get update && \
    apt-get -y install ruby ruby-dev git make build-essential libicu-dev zlib1g-dev cmake pkg-config

ADD . /tmp/copyright-header/
ADD .git /tmp/copyright-header/.git

WORKDIR /tmp/copyright-header/

RUN gem build copyright-header.gemspec && \
    gem install copyright-header-*.gem && \
    rm -rf /tmp/copyright-header

VOLUME ["/usr/src"]

WORKDIR /usr/src

ENTRYPOINT ["/usr/local/bin/copyright-header"]
