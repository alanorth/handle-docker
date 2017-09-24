# osul/handle:latest
FROM openjdk:8-jdk-alpine
MAINTAINER Corey Hinshaw <hinshaw.25@osu.edu>

ENV HSJ_VERSION 8.1.3

RUN apk add --no-cache curl tar sed

# Install Handle System server
RUN curl -fSL https://www.handle.net/hnr-source/hsj-$HSJ_VERSION.tar.gz -o hsj.tar.gz \
  && mkdir -p /opt/hs /srv/hs/svr1 \
  && tar xzf hsj.tar.gz -C /opt/hs --strip-components=1 \
  && rm hsj.tar.gz \
  && sh -c '/bin/echo -e "y\nn\n0.0.0.0\n0.0.0.0\n2641\n8000\nn\n1\nTest Handle Server\nEaxample Corp\n\n\ninfo@example.com\nn\nn\nn\n" | /opt/hs/bin/hdl-setup-server /srv/hs/svr1'

# Copy known server configuration files
COPY config/ /srv/hs/svr1/

# Configure handle client
RUN mkdir -p ~/.handle \
  && cp /srv/hs/svr1/siteinfo.json ~/.handle/resolver_site \
  && sed -i 's/0.0.0.0/127.0.0.1/g' ~/.handle/resolver_site \
  && echo "*" > ~/.handle/local_nas

ENV PATH /opt/hs/bin:$PATH

VOLUME /srv/hs/svr1

EXPOSE 8000 2641

CMD ["hdl-server", "/srv/hs/svr1"]
