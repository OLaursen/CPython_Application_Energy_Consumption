#!/bin/bash

#Install dependencies
sudo pkg install -y gmake gettext-runtime gettext-tools indexinfo libffi libtextstyle mpdecimal pkgconf readline pyenv

#Setup environment for pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc
source ~/.bashrc

#Set compile flags
export MAKE=gmake
export CPPFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export PKG_CONFIG_PATH="/usr/local/libdata/pkgconfig"

#Install pyenv alongside Pyperformance
VERSIONS=("3.13.7" "3.12.11" "3.11.13" "3.10.18" "3.9.23")
for VERSION in "${VERSIONS[@]}"; do
    PYTHON_BIN="$HOME/.pyenv/versions/$VERSION/bin/python"
    pyenv install $VERSION
    $PYTHON_BIN -m pip install pyperformance
done