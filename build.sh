#!/bin/bash

if [ -z "$1" ]; then
  echo "Specify an image name as an argument."
  exit 1
fi

CURRENT_MASTER=$(curl -s https://api.github.com/repos/tinyproxy/tinyproxy/git/refs/heads/master | jq -r .object.sha)
curl -s https://registry.hub.docker.com/v1/repositories/$1/tags | grep -q "\"${CURRENT_MASTER}\""
IN_TAGS=$?

if [ ! -z "${HUB_USER}" ] && [ "${IN_TAGS}" -eq 0 ]; then
  echo "Commit ${CURRENT_MASTER} already has an image pushed to Docker Hub for $1"
  exit 0
fi

set -e

docker build --no-cache -t $1-nonstrip .
COMMIT=$(docker run --entrypoint /bin/cat $1-nonstrip /.commit)
./strip-docker-image -i $1-nonstrip -t $1 -f /tmp -f /bin -f /sbin -f /lib -f /etc -f /usr/bin -f /usr/lib -f /usr/local -f /usr/sbin -f /lib64 -f /var/run
docker tag $1:latest $1:${COMMIT}
docker push $1:latest
docker push $1:${COMMIT}
