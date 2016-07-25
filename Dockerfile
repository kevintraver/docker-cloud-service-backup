FROM ruby:2.3.1
MAINTAINER Kevin Traver
RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y install git

RUN mkdir -p /root/.ssh

RUN gem install docker_cloud
RUN gem install git

COPY . /
RUN chmod +x ./docker-entrypoint.sh

ENV REPO_DIR "/repo"
ENV REPO_NAME "docker-backup"

ENTRYPOINT ["/docker-entrypoint.sh"]
