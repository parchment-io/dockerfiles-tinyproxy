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

docker build --no-cache -t $1:latest .
COMMIT=$(docker run --entrypoint /bin/cat $1:latest /.commit)
docker tag $1:latest $1:${COMMIT}
docker push $1:latest
docker push $1:${COMMIT}
