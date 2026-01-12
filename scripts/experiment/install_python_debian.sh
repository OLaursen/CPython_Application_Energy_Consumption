#!/bin/bash

# Install pyenv
sudo apt update
sudo apt install make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl git \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

curl https://pyenv.run | bash

# Set pyenv in path
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
source ~/.bashr

# Install Python versions via pyenv
VERSIONS=("3.13.7" "3.12.11" "3.11.13" "3.10.18" "3.9.23")
for VERSION in "${VERSIONS[@]}"; do
    PYTHON_BIN="~/.pyenv/versions/$VERSION/bin/python"
    $PYTHON_BIN install $VERSION
    $PYTHON_BIN -m pip install pyperformance

done

echo "Installation complete!"
