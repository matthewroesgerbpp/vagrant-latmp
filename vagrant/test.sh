#!/usr/bin/env bash
# shellcheck source=/dev/null

# To see what packages `groupinstall` installs, run:
# $ yum groups info development
sudo yum --assumeyes groups install
sudo yum --assumeyes groupinstall development

# Additional packages needed:
sudo yum --assumeyes install \
  bzip2-devel \
  curl \
  gnupg2 \
  libyaml-devel \
  openssl-devel \
  readline-devel \
  sqlite-devel \
  zlib-devel

bundle install \
--path /var/ruby/test/ \
--gemfile /var/ruby/test/Gemfile
