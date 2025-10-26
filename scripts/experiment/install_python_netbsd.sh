#!/bin/sh
set -eu
export PATH=$PATH:/usr/pkg/bin:/usr/pkg/sbin

# Function to install a specific Python version with optimizations on NetBSD
install_python() {
    VERSION=$1
    MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f1,2)
    PYTHON_BIN="/usr/local/bin/python${MAJOR_MINOR}"
    PYTHON_SRC="Python-${VERSION}"
    PYTHON_TGZ="${PYTHON_SRC}.tgz"
    SWAPFILE="/swapfile"

    # Check if Python version is already installed
    if [ -x "$PYTHON_BIN" ] && [ "$($PYTHON_BIN --version 2>&1)" = "Python $VERSION" ]; then
        echo "$PYTHON_SRC is already installed."
        return
    fi

    echo "Installing $PYTHON_SRC with optimizations..."

    # Install build dependencies
    pkgin -y update
    doas pkgin -y in gmake git bash wget curl pkgconf libffi \
        readline sqlite3 openssl zlib xz tk bzip2

    # Fetch and compile Python from source
    cd /tmp || exit 1
    echo "Downloading $PYTHON_SRC..."
    ftp https://www.python.org/ftp/python/${VERSION}/${PYTHON_SRC}.tgz
    tar -xzf "$PYTHON_TGZ"
    cd "$PYTHON_SRC" || exit 1

    echo "Configuring and compiling Python $VERSION..."
    ./configure --prefix=/usr/local --enable-optimizations --with-lto
    CPU_COUNT=$(sysctl -n hw.ncpu)
    
    echo "Create temporary swapfile for lto..."
    doas dd if=/dev/zero of=$SWAPFILE bs=1m count=2048
    doas chmod 600 $SWAPFILE
    doas swapctl -a $SWAPFILE
    echo "Swap created"
    /sbin/swapctl -l

    echo "Making LTO optimized build..."
    gmake -j "$CPU_COUNT" profile-opt 
    doas gmake altinstall
    
    echo "Deleteing temporary swapfile.."
    if /sbin/swapctl -l | grep -q "$SWAPFILE"; then
        doas swapctl -d $SWAPFILE
        doas rm -f $SWAPFILE
        echo "Swap removed"
    else
        echo "Swap not active"
    fi

    echo "Cleaning up build files..."
    cd ..
    rm -rf "$PYTHON_SRC" "$PYTHON_TGZ"
    
    echo "Ensuring pip is installed..."
    # Ensure pip is installed
    "$PYTHON_BIN" -m ensurepip

    echo "Veryting installation..."
    # Verify installation
    "$PYTHON_BIN" --version

    echo "Install pyperformance if not already present"
    if ! "$PYTHON_BIN" -m pip show pyperformance >/dev/null 2>&1; then
        echo "Installing pyperformance for $PYTHON_BIN..."
        "$PYTHON_BIN" -m pip install --upgrade pip
        "$PYTHON_BIN" -m pip install pyperformance
    else
        echo "pyperformance is already installed for $PYTHON_BIN."
    fi
    echo "Finished installing Python $VERSION"
}

# Install desired Python versions
#install_python "3.9.22"
install_python "3.10.18"
install_python "3.11.14"
install_python "3.12.11"
install_python "3.13.9"
#install_python "3.14.0"

echo "Installation complete!"
