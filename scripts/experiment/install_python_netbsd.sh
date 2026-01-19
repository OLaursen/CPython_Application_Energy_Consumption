#!/bin/sh

export PATH="/usr/pkg/bin:/usr/pkg/sbin:/usr/local/bin:/usr/bin:/bin"
install_python(){
        VERSION=$1
        MAJOR_MINOR=$(echo "$VERSION" | cut -d. -f1,2)
        PYTHON_BIN="/usr/pkg/bin/python${MAJOR_MINOR}"
        PYTHON_SRC="Python-$VERSION"
        PYTHON_TGZ="$PYTHON_SRC.tgz"
        BUILDDIR="$HOME/build/python${MAJOR_MINOR}"
        echo "This is the build dir: $BUILDDIR"
        # Check if Python version is already installed
        # if [ -x "$PYTHON_BIN" ] && [ "$($PYTHON_BIN --version 2>&1)" = "Python $VERSION" ]; then
        #     echo "$PYTHON_SRC is already installed."
        #     return
        # fi

        echo "Fetching Python from source"
        cd
        mkdir -p $BUILDDIR
        cd $BUILDDIR
        echo "Downloading $PYTHON_SRC..."
        ftp https://www.python.org/ftp/python/${VERSION}/${PYTHON_SRC}.tgz
        tar -xzf "$PYTHON_TGZ"
        cd "$PYTHON_SRC"
        
        #Ensures openssl can be found:
      
        export PKG_CONFIG_PATH="/usr/pkg/lib/pkgconfig"
        export CPPFLAGS="-I/usr/pkg/include"
        export LDFLAGS="-L/usr/pkg/lib -Wl,-R/usr/pkg/lib"
        export CFLAGS="-std=gnu99 -D_GNU_SOURCE"
        # CPPFLAGS="-I/usr/pkg/include" \
        # LDFLAGS="-L/usr/pkg/lib -Wl,-R/usr/pkg/lib"

        
        echo "Configuring the build with optimizations..."
        ./configure --prefix=/usr/local \
                --enable-optimizations \
                --with-ensurepip=upgrade \
                --with-openssl=/usr/pkg \
                --with-openssl-rpath=/usr/pkg/lib \


        echo "Building Python $VERSION"
        gmake -j$(sysctl -n hw.ncpu) profile-opt
        gmake altinstall
        if [ ! -x "$PYTHON_BIN" ]; then
                echo "Build or installation failed for Python $VERSION"
        fi
        
        echo "Cleaning up build files..."
        cd ..
        rm -rf "$PYTHON_SRC" "$PYTHON_TGZ"

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
doas pkgin -y in gmake git bash wget curl pkgconf libffi \
        readline sqlite3 openssl zlib xz tk bzip2 libuuid \
        gcc clang cmake autoconf automake libtool mpdecimal \
        zstd tcl sudo ncurses

# Install pyenv


# Set pyenv in path

echo '
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"
' >> ~/.profile
. ~/.profile

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

CPPFLAGS="-I/etc/openssl/include" \
LDFLAGS="-L/etc/openssl/lib" \
pyenv install -v -s "3.13.7"

# Applying a patch to pyenv
#Assuming that patches are in "~/patchesXXX"
cd 
cd patches313
patches=""

for file in *.patch; do
    echo "Applying patch $file"
    patches="$patches$file "
done

echo "All patches to apply: $patches"