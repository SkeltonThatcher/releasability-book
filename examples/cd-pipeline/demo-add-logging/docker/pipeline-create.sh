#!/usr/bin/env bash

# make sure Jenkins log file exists before docker-compose to avoid it gets created as a 
# directory when mounted on a container
mkdir -p /volumes/jenkins/
touch /volumes/jenkins/jenkins.log

docker-compose down -v
docker-compose rm -v filebeat
docker-compose build
docker-compose up -d

docker logs -f -t jenkins &> /volumes/jenkins/jenkins.log &
