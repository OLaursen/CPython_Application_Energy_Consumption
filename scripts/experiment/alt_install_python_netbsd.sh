#!/bin/sh
export PATH=$PATH:/usr/pkg/bin:/usr/pkg/sbin

#Before running this script, ensure that a version of python is available and that psutil is manually installed and corrected:
#### Python

# Install build dependencies
doas pkgin -y update
doas pkgin -y in gmake git bash wget curl pkgconf libffi \
        readline sqlite3 openssl zlib xz tk bzip2 libuuid \
        gcc clang cmake autoconf automake libtool mpdecimal \
        zstd 

# Install Python Seperate from experiement
doas pkgin in python39
python3.9 -m ensurepip
python3.9 -m pip install --upgrade pip



#### Manually install Psutil
cd /tmp
Update pkgin
ftp https://files.pythonhosted.org/packages/source/p/psutil/psutil-7.1.2.tar.gz
tar -xzf psutil-7.1.2.tar.gz
cd psutil-7.1.2

#Then within the "kinfo_getfile" method find the line "psutil_debug("exceeded INT_MAX")" and add the missing ";"
#Then from within the psutil-7.1.2 directory run():

python3.9 -m pip install . --no-binary=:all:

#Download Cpython repo for benchmarks
mkdir -p ~/pybench_results ~/pybench_builds
cd
git clone https://github.com/python/cpython.git
git fetch --tags


cd
cd ~/cpython_application_energy_consumption/scripts/experiment/
python3.9 -m pip install pyperformance
python3.9 -m pyperformance compile_all ./benchmark.conf
    


echo which python3.10
echo which python3.11
echo which python3.12
echo which python3.13
echo which python3.14