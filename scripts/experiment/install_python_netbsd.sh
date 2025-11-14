#!/bin/sh
export PATH=$PATH:/usr/pkg/bin:/usr/pkg/sbin

# Install build dependencies
doas pkgin -y update
doas pkgin -y in gmake git bash wget curl pkgconf libffi \
        readline sqlite3 openssl zlib xz tk bzip2 libuuid \
        gcc clang cmake autoconf automake libtool mpdecimal \
        zstd tcl sudo python313 # At the time of writing it's 3.13.9

# Install Python Separate from experiement
doas python3.13 -m ensurepip
doas python3.13 -m pip install --upgrade pip

# Manually downloaded and corrected psutil repository
cd ~/psutil
doas python3.13 -m pip install . --no-binary=:all:

#Download Cpython repo for benchmarks
mkdir -p ~/pybench_results ~/pybench_builds

cd
git clone https://github.com/python/cpython.git
cd cpython
git fetch --tags #Needed inorder to compile python verions via tags

#Ensures openssl can be found:
export CPPFLAGS="-I/usr/pkg/include"
export LDFLAGS="-L/usr/pkg/lib -Wl,-R/usr/pkg/lib"
export PKG_CONFIG_PATH="/usr/pkg/lib/pkgconfig"
export CFLAGS="-std=gnu99 -D_GNU_SOURCE"

#Use all cpu cores
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)" 
doas python3.13 -m pip install pyperformance pyperf
doas python3.13 -m pyperformance compile_all ~/cpython_application_energy_consumption/scripts/experiment/benchmark.conf

mkdir -p ~/pybench_builds/
echo which python3.13
echo "Installation complete!"