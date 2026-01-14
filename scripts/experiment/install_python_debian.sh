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
    PYTHON_BIN="$HOME/.pyenv/versions/$VERSION/bin/python"
    pyenv install $VERSION
    $PYTHON_BIN -m pip install pyperformance

done

# Find project directory or clone it
if [[ -d "$HOME/CPython_Application_Energy_Consumption" ]]; then
    echo "Project directory found. Checking for updates."
    cd "$HOME/CPython_Application_Energy_Consumption"
    git fetch -a
    git pull
else
  echo "Project directory not found, cloning repository into HOME directory."
  cd 
  git clone "https://github.com/olaursen/CPython_Application_Energy_Consumption.git"
fi

echo "Python installation and setup complete!"