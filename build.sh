#!/usr/bin/env bash
# I could add set -e to my script, but I find that introduce some unexpected silent failures
# So I elected to catch errors as much as possible.

PACKER_CMD=$(which packer)
DOCKER_CMD=$(which docker)
PACKER_TEMPLATE="docker-nginx.json"

DOCKER_IMAGE_IMAGES="ubuntu:latest centos:latest"

# Check to see if commands are in the path.

if [ -z "${PACKER_CMD}" ]; then
  echo "Packer is not installed or not in the path"
  exit 1
fi

if [ -z "${DOCKER_CMD}" ]; then
  echo "Docker is not installed or not in the path"
  exit 1
fi

if [ ! -e "${PACKER_TEMPLATE}" ]; then
  echo "Packer template does not appear to exists in the current directory."
  exit 1
fi

for IMG in ${DOCKER_IMAGE_IMAGES}
do
  echo ${IMG}
done
