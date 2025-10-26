#!/bin/sh
set -eu
export PATH=$PATH:/usr/bin:/usr/local/bin:/usr/sbin:/usr/local/sbin
#Iso image url: https://cdn.openbsd.org/pub/OpenBSD/7.7/arm64/install77.iso
# Function to install a specific Python version with optimizations on OpenBSD
install_python() {
    VERSION=$1
    MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f>1,2)
    PYTHON_BIN="/usr/local/bin/python${MAJOR_MINOR}"
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

    echo "Installing build dependencies..."
    doas pkg_add git bash wget curl gmake pkgconf \
        libffi readline sqlite3 openssl zlib xz tk \
        bzip2 lzma gcc

    echo "Fetching python source"
    cd /tmp || exit 1
    ftp https://www.python.org/ftp/python/${VERSION}/${PYTHON_TGZ}
    tar -xzf "$PYTHON_TGZ}"
    cd "$PYTHON_SRC" || exit 1

    echo "Configuring and compiling Python $VERSION..."
    ./configure --prefix=/usr/local --enable-optimizations --with-lto
    CPU_COUNT=$(sysctl -n hw.ncpuonline)

    echo "Creating swapfile for lto"
    doas dd if=/dev/zero of="$SWAPFILE" bs=1m count=2048
    doas chmod 600 "$SWAPFILE"
    doas vnconfig vnd0 "$SWAPFILE"
    doas swapon /dev/vnd0b
    swapctl -l 

    #make lto
    gmake -j "$CPU_COUNT" profile-opt
    doas gmake altinstall 
    
    #Remove swapfile
    if swapctl -l | grep -q "/dev/vnd0b"; then
        doas swapoff /dev/vnd0b
        doas vnconfig -u vnd0
        doas rm -f "$SWAPFILE"
        echo "Swapfile removed."
    else
        echo "Swapfile not active or missing."
    fi
    echo "Cleaning up build files..."
    cd ..
    rm -rf Python-${VERSION} Python-${VERSION}.tgz

    # Ensure pip is installed
    "$PYTHON_BIN" -m ensurepip

    # Verify installation
    "$PYTHON_BIN" --version

    # Install pyperformance if not already present
    if ! "$PYTHON_BIN" -m pip show pyperformance >/dev/null 2>&1; then
        echo "Installing pyperformance for $PYTHON_BIN..."
        "$PYTHON_BIN" -m pip install --upgrade pip
        "$PYTHON_BIN" -m pip install pyperformance
    else
        echo "pyperformance is already installed for $PYTHON_BIN."
    fi
    echo "finished installing $PYTHON_SRC"
}

# Install desired Python versions
install_python "3.9.22"
#install_python "3.10.17"
#install_python "3.11.12"
#install_python "3.12.10"
#install_python "3.13.3"

echo "Installation complete!"
