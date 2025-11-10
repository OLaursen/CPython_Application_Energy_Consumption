#!/bin/sh
export PATH=$PATH:/usr/pkg/bin:/usr/pkg/sbin

# Install build dependencies
doas pkgin -y update
doas pkgin -y in gmake git bash wget curl pkgconf libffi \
        readline sqlite3 openssl zlib xz tk bzip2 libuuid \
        gcc clang cmake autoconf automake libtool mpdecimal \
        zstd tcl

# Install Python Seperate from experiement
doas pkgin in python313 # At the time of writing it's 3.13.9
python3.13 -m ensurepip
python3.13 -m pip install --upgrade pip

#### Manually install Psutil
cd /tmp
Update pkgin
ftp https://files.pythonhosted.org/packages/source/p/psutil/psutil-7.1.2.tar.gz
tar -xzf psutil-7.1.2.tar.gz
cd psutil-7.1.2

#Then within the "kinfo_getfile" method find the line "psutil_debug("exceeded INT_MAX")" and add the missing ";"
#Then from within the psutil-7.1.2 directory run:
python3.13 -m pip install . --no-binary=:all:

#Download Cpython repo for benchmarks
mkdir -p ~/pybench_results ~/pybench_builds
cd
git clone https://github.com/python/cpython.git
git fetch --tags #Needed inorder to compile python verions via tags

#Ensures openssl can be found:
export CPPFLAGS="-I/usr/pkg/include"
export LDFLAGS="-L/usr/pkg/lib -Wl,-R/usr/pkg/lib"
export PKG_CONFIG_PATH="/usr/pkg/lib/pkgconfig"
export CFLAGS="-std=gnu99 -D_GNU_SOURCE"
#Use all available cores
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)" 

python3.13 -m pip install pyperformance
python3.13 -m pyperformance compile_all ~/cpython_application_energy_consumption/scripts/experiment/benchmark.conf
    
echo which python3.13
echo "Installation complete!"