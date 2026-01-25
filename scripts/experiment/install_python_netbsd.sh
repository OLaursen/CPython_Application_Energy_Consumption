#!/bin/sh

# Install build dependencies
doas pkgin -y update
doas pkgin -y in gmake git bash wget curl pkgconf libffi \
        readline sqlite3 openssl zlib xz tk bzip2 libuuid \
        gcc clang cmake autoconf automake libtool mpdecimal \
        zstd tcl sudo ncurses
# Install pyenv
curl https://pyenv.run | bash

# Set pyenv in path
echo '
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
' >> ~/.bashrc

. ~/.bashrc


pyenv --version
# Install Python versions via pyenv

VERSIONS="
3.13.7
3.12.11
3.11.13
3.10.18
3.9.23
"

for VERSION in $VERSIONS; do
    echo "Installing Python $VERSION"
    pyenv install -s "$VERSION" || exit 1
    PYTHON_BIN="$HOME/.pyenv/versions/$VERSION/bin/python"
    CONFIGURE_OPTS="--with-openssl=/etc/openssl"
    "$PYTHON_BIN" -m ensurepip
    "$PYTHON_BIN" -m pip install -U pip setuptools wheel
    "$PYTHON_BIN" -m pip install pyperformance
done


# Done in bash shell from home directory 
# Set C build flags
export CC=gcc
export MAKE=gmake
export PYTHON_CONFIGURE_OPTS="--with-openssl=/usr/pkg --with-openssl-rpath=auto"
export CPPFLAGS="-I/usr/pkg/include -I/usr/pkg/include/ncurses"
export LDFLAGS="-L/usr/pkg/lib -Wl,-R/usr/pkg/lib"
export PKG_CONFIG_PATH="/usr/pkg/lib/pkgconfig"
export CFLAGS="${CFLAGS:+$CFLAGS }-std=gnu11"

# Assumes that patch folder from pkgsrc repositiory are extracted to home directory named patches<major-version><minor-version>
cat patches313/* | pyenv install -v --patch 3.13.7
cat patches312/* | pyenv install -v --patch 3.12.11
cat patches311/* | pyenv install -v --patch 3.11.13
cat patches310/* | pyenv install -v --patch 3.10.18
cat patches39/* | pyenv install -v --patch 3.9.23

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