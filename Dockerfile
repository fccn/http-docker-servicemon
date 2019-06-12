#----------------------------------------------------------
# Docker Image for a Python monitor for docker instances
# - configurations on optional folder for easyer overrides
# - adapted for reverse proxy use
# - additional configs for simplesamlphp
# - nginx runs as application user
#----------------------------------------------------------
FROM python:3-alpine
LABEL maintainer="Paulo Costa <paulo.costa@fccn.pt>"

#---- Read build args
ARG HOST_PORT=4000
ARG SERVICE_NAME=

ENV TZ=Europe/Lisbon
ENV PORT=$HOST_PORT
ENV SERVICE_NAME=$SERVICE_NAME

#add testing and community repositories
RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
  && echo '@community http://nl.alpinelinux.org/alpine/edge/community' >> /etc/apk/repositories \
  && echo '@edge http://nl.alpinelinux.org/alpine/edge/main' >> /etc/apk/repositories \
  && apk update && apk upgrade --no-cache --available && apk add --upgrade apk-tools@edge \
#------ set timezone
  ; apk --no-cache add ca-certificates && update-ca-certificates \
  ; apk add --update tzdata && cp /usr/share/zoneinfo/Europe/Lisbon /etc/localtime \
#--- additional packages
  ; rm -rf /var/cache/apk/*

#-Add contents
WORKDIR /app
COPY ./src /app
COPY monitor-docker.sh /monitor-docker.sh
COPY test-monitor.sh /test-monitor.sh
#store version info
COPY VERSION /app/VERSION

RUN chmod o+x /*.sh && \
#    pip install requests-unixsocket==0.1.5 && \
    pip install docker && \
# Verify docker image
    pip show docker | grep "docker"
#    pip show requests-unixsocket | grep "0.1.5"

ENTRYPOINT ["/monitor-docker.sh"]
