#!/bin/bash

IMAGE_VERSION='0.2.4'

docker rmi -f jorvis/gales-gce
docker build --no-cache -t jorvis/gales-gce:latest -t jorvis/gales-gce:${IMAGE_VERSION} .
docker images

echo "If ready for release, run: "
echo "  docker push jorvis/gales-gce:latest"
echo "  docker push jorvis/gales-gce:${IMAGE_VERSION}"
