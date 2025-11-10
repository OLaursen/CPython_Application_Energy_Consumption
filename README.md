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

