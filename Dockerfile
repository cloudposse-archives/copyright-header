FROM ubuntu:18.04

RUN apt-get update && \
    apt-get -y install ruby ruby-dev git make build-essential libicu-dev zlib1g-dev cmake pkg-config cmake libssl-dev

# Set the locale
# make the "en_US.UTF-8" locale so ruby will be utf-8 enabled by default
RUN apt-get update  && apt-get install -y --no-install-recommends apt-utils && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ADD . /tmp/copyright-header/
ADD .git /tmp/copyright-header/.git

WORKDIR /tmp/copyright-header/

RUN gem build copyright-header.gemspec && \
    gem install copyright-header-*.gem && \
    rm -rf /tmp/copyright-header

VOLUME ["/usr/src"]

WORKDIR /usr/src

ENTRYPOINT ["/usr/local/bin/copyright-header"]
