#!/usr/bin/env bash

if [ -e "/etc/redhat-release" ]; then
  yum -y install epel-release
  yum -y install ansible
else
  apt update
  apt -y install software-properties-common
  apt-add-repository --yes --update ppa:ansible/ansible
  apt -y install ansible
fi
