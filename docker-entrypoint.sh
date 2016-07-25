#!/bin/sh
mkdir -p $REPO_DIR

eval `ssh-agent`
ssh-keyscan github.com >> /root/.ssh/known_hosts
ssh-add docker-test

ruby ./docker_listen.rb
