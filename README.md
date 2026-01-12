## Python Application Energy Consumption
This is the companion repository for the thesis *"Python Application Energy Consumption: Investigating Operating System, Python Version and Hardware Impact on the Energy Consumption of Application Benchmarks"*.

The repository contains all the code used to run the experiment for measuring the energy consumption of application benchmarks presented in the thesis. 

The repository also contains all results reported in the thesis.

For the full insctruction set for running the experiment, see the wiki found on this page.

The contents herein are made freely available under the MIT license.

All the code herein was written with some assistance from ChatGPT.


## Experiment notes
- Needs to have enable ssh mounted in the disk image
- - Enable ssh - use PaswordAuthentication
- Also have to set password and user if ssh'ing

FreeBSD is not supported on pi5, so only pi4 images are created for FreeBSD.
#### On controller pc ensure that:
otii-tcp-client and paramiko is installed. 



#### Needed to add swapfile inorder to complete install_python script on ubuntu with pi3b+:

pi@ubuntu:~$ sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
Setting up swapspace version 1, size = 2 GiB (2147479552 bytes)
no label, UUID=61cfe5fb-6ffd-4433-8ed1-28db9ea4803a
pi@ubuntu:~$ free -h
               total        used        free      shared  buff/cache   available
Mem:           896Mi       445Mi       354Mi       139Mi       313Mi       451Mi
Swap:          2.0Gi          0B       2.0Gi

## Running the experiment on NetBSD
- Ensure that psutil is installed in the home folder. 
- Ensure that sudo is installed an available for the user running the benchmarks. 
- Can be a good idea to enable a swapfile when running on systems with low memory. 
#### Setting up sudo
doas pkgin -y in sudo
Enable sudo for the user. I Uncommented the line:

```bash
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
```
Inorder to enable passwordless sudo for wheel group users.

#### Manually install Psutil
```bash
cd /tmp
doas pkgin -y update
ftp https://files.pythonhosted.org/packages/source/p/psutil/psutil-7.1.2.tar.gz
tar -xzf psutil-7.1.2.tar.gz
cd psutil-7.1.2
```
Then within the "kinfo_getfile" method find the line "psutil_debug("exceeded INT_MAX")" and add the missing ";"
Then from within the psutil-7.1.2 directory run:

#### Activitating swapfile
Creating a 2gb swapfile named "swapfile". 
```bash
doas dd if=/dev/zero of=/swapfile bs=1m count=2048
doas chmod 600 /swapfile
doas swapctl -a /swapfile
```


#### Setup ubuntu
sudo apt update
sudo apt install git net-tools
sudo systemctl enable --now ssh
git clone https://