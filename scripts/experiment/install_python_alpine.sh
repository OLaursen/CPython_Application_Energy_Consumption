#!/bin/bash

# Function to install a specific Python version with optimizations on Alpine Linux
install_python() {
    VERSION=$1
    PYTHON_BIN="/usr/local/bin/python${VERSION%.*}"

    # Check if the version is already installed
    if [ -x "$PYTHON_BIN" ] && [[ "$($PYTHON_BIN --version 2>&1)" == *"$VERSION"* ]]; then
        echo "Python $VERSION is already installed."
    else
        echo "Installing Python $VERSION with optimizations..."

        # Update package list (apk doesn't need update in the same way as apt)
        apk update

        curl -O https://www.python.org/ftp/python/$VERSION/Python-$VERSION.tgz
        tar -xvzf Python-$VERSION.tgz
        cd Python-$VERSION

        # Configure the build with the necessary flags
        ./configure --prefix=/usr/local --enable-optimizations --with-ensurepip

        # Build Python with profile-guided optimizations (PGO)
        make -j "$(nproc)" profile-opt

        # Install Python
        make altinstall

        # Clean up
        rm -rf Python-$VERSION Python-$VERSION.tgz

        # Ensure pip is installed
        $PYTHON_BIN -m ensurepip

        # Verify installation
        $PYTHON_BIN --version
    fi

    # Install pyperformance if not already installed
    if ! $PYTHON_BIN -m pip show pyperformance &>/dev/null; then
        echo "Installing pyperformance for $PYTHON_BIN..."
        $PYTHON_BIN -m pip install --upgrade pip
        $PYTHON_BIN -m pip install pyperformance
    else
        echo "pyperformance is already installed for $PYTHON_BIN."
    fi
}
#Download Cpython repo for benchmarks
mkdir -p ~/pybench_results ~/pybench_builds
cd
git clone https://github.com/python/cpython.git
git fetch --tags #Needed inorder to compile python verions via tags

# Install Python versions with optimizations
install_python "3.13.9"
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)" 
python3.13 -m pyperformance compile_all ~/cpython_application_energy_consumption/scripts/experiment/benchmark.conf

echo "Installation complete!"
