#!/usr/bin/env bash
# I could add set -e to my script, but I find that introduce some unexpected silent failures
# So I elected to catch errors as much as possible.
DOCKER_CMD=$(which docker)
PACKER_CMD=$(which packer)
PACKER_TEMPLATE="docker-nginx.json"
ANSIBLE_PLAYBOOK_CMD=$(which ansible-playbook)
ANSIBLE_PLAYBOOK_FILE="nginx.yml"

# Note that by specifying just the os, it will pull the latest one by default

DOCKER_IMAGE_IMAGES="ubuntu centos"

# Check to see if commands are in the path.

if [ -z "${PACKER_CMD}" ]; then
  echo "Packer is not installed or not in the path"
  exit 1
fi

if [ -z "${DOCKER_CMD}" ]; then
  echo "Docker is not installed or not in the path"
  exit 1
fi

if [ ! -e "${ANSIBLE_PLAYBOOK_CMD}" ]; then
  echo "ansible-playbook is not installed or not in the path."
  exit 1
fi

if [ ! -e "${PACKER_TEMPLATE}" ]; then
  echo "Packer template does not appear to exists in the current directory."
  exit 1
fi

for IMG in ${DOCKER_IMAGE_IMAGES}
do
  echo ${IMG}
  ${PACKER_CMD} inspect ${PACKER_TEMPLATE}
  INSPECTION_ERROR=$?
  if [ ${INSPECTION_ERROR} -ne 0 ]; then
    echo "Exiting due to inspector error with ${PACKER_TEMPLATE}"
    exit 1
  fi
  ${PACKER_CMD} validate -var "img=${IMG}" ${PACKER_TEMPLATE}
  PACKER_VALIDATION_ERROR=$?
  if [ ${PACKER_VALIDATION_ERROR} -ne 0 ]; then
    echo "Exiting due to validation error with ${PACKER_TEMPLATE}"
    exit 1
  fi
  ${ANSIBLE_PLAYBOOK_CMD} --syntax-check ${ANSIBLE_PLAYBOOK_FILE}
  ANSIBLE_PLAYBOOK_VALIDATION_ERROR=$?
  if [ ${ANSIBLE_PLAYBOOK_VALIDATION_ERROR} -ne 0 ]; then
    echo "Exiting due to validation error with ${PACKER_TEMPLATE}"
    exit 1
  fi
done
