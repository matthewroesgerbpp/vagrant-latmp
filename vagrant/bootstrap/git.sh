#!/usr/bin/env bash
# shellcheck source=/dev/null

UPDATE

MESSAGE "Installing Git"

# Install the EPEL repository configuration package:
sudo yum --assumeyes install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# Equivalent: yum -y install epl-release

# https://ius.io/
# A reasonably up-to-date git:
sudo yum --assumeyes install https://centos7.iuscommunity.org/ius-release.rpm

# Remove stock git:
#yum erase git

# Install git:
sudo yum --assumeyes install git2u
