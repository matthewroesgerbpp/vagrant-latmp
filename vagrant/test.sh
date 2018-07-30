#!/usr/bin/env bash
# shellcheck source=/dev/null

sudo yum --assumeyes install \
  automake \
  gcc \
  gcc-c++ \
  git \
  kernel-devel \
  libgmp3-devel \
  make

bundle install \
--path /var/ruby/test/ \
--gemfile /var/ruby/test/Gemfile
