#!/bin/sh

export PATH="/usr/pkg/bin:/usr/pkg/sbin:/usr/local/bin:/usr/bin:/bin"
install_python(){
        VERSION=$1
        MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f1,2)
        PYTHON_BIN="/usr/pkg/bin/python${MAJOR_MINOR}"
        PYTHON_SRC="Python-$VERSION"
        PYTHON_TGZ="$PYTHON_SRC.tgz"
        CPU_COUNT=$(sysctl -n hw.ncpu)
        BUILDDIR="$HOME/build/python${MAJOR_MINOR}"
        echo "This is the build dir: $BUILDDIR"
        # Check if Python version is already installed
        # if [ -x "$PYTHON_BIN" ] && [ "$($PYTHON_BIN --version 2>&1)" = "Python $VERSION" ]; then
        #     echo "$PYTHON_SRC is already installed."
        #     return
        # fi

        echo "Fetching Python from source"
        mkdir -p $BUILDDIR
        cd $BUILDDIR
        echo "Downloading $PYTHON_SRC..."
        ftp https://www.python.org/ftp/python/${VERSION}/${PYTHON_SRC}.tgz
        tar -xzf "$PYTHON_TGZ"
        cd "$PYTHON_SRC"

        #Ensures openssl can be found:
        export CPPFLAGS="-I/usr/pkg/include"
        export LDFLAGS="-L/usr/pkg/lib -Wl,-R/usr/pkg/lib"
        export PKG_CONFIG_PATH="/usr/pkg/lib/pkgconfig"
        export CFLAGS="-std=gnu99 -D_GNU_SOURCE"

        echo "Configuring the build with optimizations..."
        ./configure --prefix=/usr/local --enable-optimizations --with-ensurepip=upgrade --with-system-ffi --with-openssl=/usr/pkg/ 
        
        
        echo "Building Python $VERSION using $CPU_COUNT cores..."
        gmake -j "$CPU_COUNT" profile-opt
        gmake altinstall
        if [ ! -x "$PYTHON_BIN" ]; then
                echo "Build or installation failed for Python $VERSION"

        fi
        
        echo "Cleaning up build files..."
        cd ..
        rm -rf "$PYTHON_SRC" "$PYTHON_TGZ"
        
        echo "Ensuring pip is installed..."
        "python${MAJOR_MINOR}" -m ensurepip

        echo "Verifying installation..."
        "python${MAJOR_MINOR}" --version
        
        echo "Installing pyperformance for $PYTHON_BIN..."
        "python${MAJOR_MINOR}" -m pip install --upgrade pip
        "python${MAJOR_MINOR}"  -m pip install pyperformance
        
        echo "Finished installing Python $VERSION"
        date
}
# Install build dependencies
doas pkgin -y update
doas pkgin -y in 

gmake git bash wget curl pkgconf libffi \
        readline sqlite3 openssl zlib xz tk bzip2 libuuid \
        gcc clang cmake autoconf automake libtool mpdecimal \
        zstd tcl sudo

#install_python "3.10.18"
#install_python "3.13.9"
install_python "3.12.11"
echo "Installation complete!"