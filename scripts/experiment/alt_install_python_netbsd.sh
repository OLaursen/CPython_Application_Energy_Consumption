#!/bin/sh
export PATH=$PATH:/usr/pkg/bin:/usr/pkg/sbin


# Install build dependencies
pkgin -y update
doas pkgin -y in gmake git bash wget curl pkgconf libffi \
    readline sqlite3 openssl zlib xz tk bzip2 libuuid \
    gcc clang cmake autoconf automake libtool mpdecimal \
    zstd 
# Install Python Seperate from experiement
doas pkgin in python39
python3.9 -m ensurepip
python3.9 -m pip install --upgrade pip
python3.9 -m pip install pyperformance


# Function to install a specific Python version with optimizations on NetBSD
install_python() {
    VERSION=$1
    MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f1,2)
    PYTHON_BIN="/usr/local/bin/python${MAJOR_MINOR}"
    PYTHON_SRC="Python-${VERSION}"
    PYTHON_TGZ="${PYTHON_SRC}.tgz"
    SWAPFILE="/swapfile"
    BUILDDIR="~/build/python${MAJOR_MINOR}"

    # Check if Python version is already installed
    #if [ -x "$PYTHON_BIN" ] && [ "$($PYTHON_BIN --version 2>&1)" = "Python $VERSION" ]; then
    #    echo "$PYTHON_SRC is already installed."
    #    return
    #fi

    echo "Installing $PYTHON_SRC with optimizations..."
    date

    # Fetch and compile Python from source
    mkdir -p $BUILDDIR
    cd $BUILDDIR

    echo "Downloading $PYTHON_SRC..."
    ftp https://www.python.org/ftp/python/${VERSION}/${PYTHON_SRC}.tgz
    tar -xzf "$PYTHON_TGZ"
    cd "$PYTHON_SRC" || exit 1

    echo "Configuring and compiling Python $VERSION..."
    
    #Helping python find openssl
    export CC=gcc
    export CXX=g++
    export CPPFLAGS="-I/usr/pkg/include -I/usr/X11R7/include"
    export LDFLAGS="-L/usr/pkg/lib -Wl,-R/usr/pkg/lib -L/usr/X11R7/lib -Wl,-R/usr/X11R7/lib"
    export PKG_CONFIG_PATH="/usr/pkg/lib/pkgconfig:/usr/X11R7/lib/pkgconfig"


    ./configure --prefix=/usr/local --with-lto --with-openssl=/usr/pkg/
    echo "$PYTHON_SRC has been configured, and ready for compilation."

    
}

# Install desired Python versions
#install_python "3.9.22"
install_python "3.13.9" # needed for running pyperformance on NetBSD
install_python "3.12.11"
install_python "3.11.14"
install_python "3.10.18"
#install_python "3.14.0"


echo "Installation complete!"
