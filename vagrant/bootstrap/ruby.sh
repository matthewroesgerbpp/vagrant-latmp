#!/usr/bin/env bash

UPDATE

MESSAGE "Installing Ruby"

# Basic Ruby CentOS install:
# yum --assumeyes install \
#   ruby \
#   ruby-devel \
#   rubygems

# Required:
sudo yum --assumeyes install \
  curl \
  gnupg2

# Dependencies required for some versions of Ruby:
sudo yum --assumeyes install \
  libyaml-devel
  # Others?

# Import public key:
gpg2 \
  --keyserver hkp://keys.gnupg.net \
  --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3

# Refresh keys:
gpg2 --refresh-keys

# Trust developers:
echo 409B6B1796C275462A1703113804BB82D39DC0E3:6: | gpg2 --import-ownertrust # mpapis@gmail.com

# Download and install RVM (single user installtion):
curl \
  --silent \
  --show-error \
  --location https://get.rvm.io \
  | bash -s stable

# Load RVM environment variable:
source ~/.rvm/scripts/rvm

# Install all Ruby system dependencies:
rvm requirements
# Installs things like:
# patch, autoconf, automake, bison, gcc-c++, libffi-devel, libtool,
# patch, readline-devel, sqlite-devel, zlib-devel, glibc-headers,
# glibc-devel, openssl-devel

# Get a list of available ruby versions that can be installed on the system:
# rvm list known

# Use pre-built Ruby binaries for faster install times!
# https://github.com/rvm/rvm/blob/master/config/remote

# Install desired Ruby version:
rvm install ruby-${RUBY_VERSION}

# Set default version of Ruby:
rvm use ${RUBY_VERSION} --default

ruby --version

# Install Bundler:
gem install bundler --no-document

#
# Apache vhost code here …
#

# Vagrant shared folders should have done this already:
sudo mkdir --parents /var/ruby
sudo chown -R vagrant:vagrant /var/ruby

# Create a Gemfile:
cat << "EOF" > /var/ruby/test/Gemfile
source 'https://rubygems.org'
gem 'sinatra', :github => 'sinatra/sinatra'
EOF

# Create an index file:
cat << "EOF" > /var/ruby/test/index.rb
require 'sinatra'
get '/' do
  'Hello world!'
end
EOF

# bundle exec ruby /var/ruby/test/index.rb

# NEEDS MORE WORK!!!!
# https://github.com/mhulse/vagrant-latmp/issues/117
