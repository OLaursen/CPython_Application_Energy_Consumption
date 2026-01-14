#!/bin/bash

# Install dependencies
apk update
apk add --no-cache bash git curl ca-certificates build-base \
    linux-headers openssl-dev bzip2-dev zlib-dev xz-dev libffi-dev \
    readline-dev sqlite-dev ncurses-dev libssl3 musl expat-dev \
    gdbm-dev mpdecimal-dev 

# Install pyenv
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
curl https://pyenv.run | bash

cat >> ~/.bashrc <<'EOF'
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
EOF
source ~/.bashrc

# Install python versions
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

