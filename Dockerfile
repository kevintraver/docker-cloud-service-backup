FROM ruby:2.3.1-alpine
MAINTAINER Kevin Traver
RUN apk update && apk upgrade
RUN apk add build-base
RUN apk add git
RUN apk add openssh

RUN mkdir -p /root/.ssh

RUN gem install docker_cloud
RUN gem install git

COPY . /
RUN chmod +x ./docker-entrypoint.sh

ENV REPO_DIR "/repo"
ENV REPO_NAME "docker-backup"

ENTRYPOINT ["/docker-entrypoint.sh"]
