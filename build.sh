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
  OS=$(echo ${IMG} | awk -F: '{print $1}')
  echo ${OS}
  echo ${IMG}
  packer inspect ${PACKER_TEMPLATE}
  INSPECTION_ERROR=$?
  if [ ${INSPECTION_ERROR} -ne 0 ]; then
    echo "Exiting due to inspector error with ${PACKER_TEMPLATE}"
    exit 1
  fi
  packer validate  -var "img=${IMG}" -var "img=${OS}" ${PACKER_TEMPLATE}
  VALIDATION_ERROR=$?
  if [ ${VALIDATION_ERROR} -ne 0 ]; then
    echo "Exiting due to validation error with ${PACKER_TEMPLATE}"
    exit 1
  fi
done
