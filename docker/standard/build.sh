#!/bin/bash

IMAGE_VERSION='0.2.0'

docker rmi -f umigs/gales
docker build --no-cache -t umigs/gales:latest -t umigs/gales:${IMAGE_VERSION} .
docker images

echo "If ready for release, run: "
echo "  docker push umigs/gales:latest"
echo "  docker push umigs/gales:${IMAGE_VERSION}"
