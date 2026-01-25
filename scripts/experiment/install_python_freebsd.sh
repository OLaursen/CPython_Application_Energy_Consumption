#!/bin/bash

#Get dependencies
 sudo pkg install gettext-runtime gettext-tools indexinfo libffi libtextstyle mpdecimal pkgconf readline pyenv
#Install pyenv

#Setup environment for pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bashrc

source ~/.bashrc
export MAKE=gmake
export CPPFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export PKG_CONFIG_PATH="/usr/local/libdata/pkgconfig"

pyenv install 3.13.7