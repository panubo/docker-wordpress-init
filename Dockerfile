# FROM alpine:latest
# Can't use alpine until this is closed https://github.com/gliderlabs/docker-alpine/issues/8
#RUN apk add --update bash findutils gzip mariadb-client && \
#    rm -rf /var/cache/apk/*

MAINTAINER Andrew Cutler <andrew@panubo.com>

FROM debian:jessie

RUN apt-get update && \
    apt-get -y install bash findutils gzip mariadb-client && \
    rm -rf /var/lib/apt/lists/*

COPY run.sh /

CMD ["/run.sh"]
