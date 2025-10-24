#!/bin/sh
export PATH=$PATH:/usr/pkg/bin:/usr/pkg/sbin

#Iso image url: https://cdn.openbsd.org/pub/OpenBSD/7.7/arm64/install77.iso
# Function to install a specific Python version with optimizations on FreeBSD
install_python() {
    VERSION=$1
    MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f1,2)
    PYTHON_BIN="/usr/local/bin/python${MAJOR_MINOR}"

    # Check if Python version is already installed
    if [ -x "$PYTHON_BIN" ] && [ "$($PYTHON_BIN --version 2>&1)" = "Python $VERSION" ]; then
        echo "Python $VERSION is already installed."
        return
    fi

    echo "Installing Python $VERSION with optimizations..."

    # Install build dependencies
    pkgin update
    doas pkgin in gmake git bash wget curl \ pkgconf libffi readline sqlite3 \ openssl zlib xz tk bzip2 lzma

    # Fetch and compile Python from source
    cd /tmp || exit 1
    ftp https://www.python.org/ftp/python/${VERSION}/Python-${VERSION}.tgz
    tar -xvzf Python-${VERSION}.tgz
    cd Python-${VERSION} || exit 1

    ./configure --enable-optimizations --with-lto
    CPU_COUNT=$(sysctl -n hw.ncpu)
    
    
    #Create swapfiles for lto
    doas dd if=/dev/zero of=/swapfile bs=1m count=2048
    doas chmod 600 /swapfile
    doas swapctl -a /swapfile
    echo "Swap created"
    swapctl -l

    #make lto
    gmake -j "$CPU_COUNT" profile-opt 
    doas gmake altinstall
    
    #Remove swapfile
    if [swapctl -l | grep -q "swapfile"]; then
        doas swapctl -d /swapfile
        doas rm -f "swapfile"
        echo "Swapå removed"
    else
        echo "Swap not active"
    fi

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
}

# Install desired Python versions
install_python "3.9.22"
#install_python "3.10.17"
#install_python "3.11.12"
#install_python "3.12.10"
#install_python "3.13.3"

echo "Installation complete!"
