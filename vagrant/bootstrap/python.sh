#!/usr/bin/env bash
# shellcheck source=/dev/null

UPDATE

MESSAGE "Installing Python"

# To see what packages `groupinstall` installs, run:
# $ yum groups info development
sudo yum --assumeyes groups install
sudo yum --assumeyes groupinstall development

# Additional packages needed:
sudo yum --assumeyes install \
  openssl-devel \
  zlib-devel \
  readline-devel \
  sqlite-devel \
  bzip2-devel

# Add to custom profile:
cat << "EOF" > ~/.bash_vagrant
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
EOF

source ~/.bash_vagrant

pyenv install ${PYTHON_VERSION}

pyenv global ${PYTHON_VERSION}

pyenv rehash

## Make demo python site here.
