## Python Application Energy Consumption
This is the companion repository for the thesis *"Python Application Energy Consumption: Investigating Operating System, Python Version and Hardware Impact on the Energy Consumption of Application Benchmarks"*.

The repository contains all the code used to run the experiment for measuring the energy consumption of application benchmarks presented in the thesis. 

The repository also contains all results reported in the thesis.

For the full insctruction set for running the experiment, see the wiki found on this page.

The contents herein are made freely available under the MIT license.

All the code herein was written with some assistance from ChatGPT.


## Dockerfile for building images on non-arm64 hosts
From root folder:

```bash
docker build -t create_images .
```
Then run the container with the following command:

```bash
docker run -it --rm --privileged \
  -v ./scripts/experiment:/workspace/experiment \
  -v ./outputs:/workspace/output \
  create_images
```
## Creating the images for ubuntu
 
```bash
#Need to be in the experiment folder, due to hardcoded paths in the *.pkr.hcl files
packer init setup/Image_creation/ubuntu.pkr.hcl
packer validate setup/Image_creation/ubuntu.pkr.hcl
packer build setup/Image_creation/ubuntu.pkr.hcl
```

## Dockerfile for building images on non-arm64 hosts (NOT WORKING)
From root folder:

```bash
docker build -t create_images .
```
Then run the container with the following command:

```bash
docker run -it --rm --privileged \
  -v ./scripts/experiment:/workspace/experiment \
  -v ./outputs:/workspace/output \
  create_images
```
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

## Arm-image plugin for packer docs:
command_wrapper (string) - Lets you prefix all builder commands, such as with ssh for a remote build host. Defaults to "". Copied from other builders :

output_directory (string) - Output directory, where the final image will be stored. Deprecated - Use OutputFile instead

output_filename (string) - Output filename, where the final image will be stored

image_type (utils.KnownImageType) - Image type. this is used to deduce other settings like image mounts and qemu args. If not provided, we will try to deduce it from the image url. (see autoDetectType()) For list of valid values, see: pkg/image/utils/images.go

image_arch (arch.KnownArchType) - Image's target CPU architecture. This is used to determine if qemu is necessary and which flavor to use. Defaults to "arm". For list of valid values, see: pkg/image/arch/arch.go

image_mounts ([]string) - Where to mounts the image partitions in the chroot. first entry is the mount point of the first partition. etc..

mount_path (string) - The path where the volume will be mounted. This is where the chroot environment will be. Will be a temporary directory if left unspecified.

chroot_mounts ([][]string) - What directories mount from the host to the chroot. leave it empty for reasonable defaults. array of triplets: [type, device, mntpoint].

additional_chroot_mounts ([][]string) - What directories mount from the host to the chroot, in addition to the default ones. Use this instead of chroot_mounts if you want to add to the existing defaults instead of overriding them array of triplets: [type, device, mntpoint]. for example: ["bind", "/run/systemd", "/run/systemd"]

resolv-conf (ResolvConfBehavior) - Can be one of: off, copy-host, bind-host, delete. Defaults to off

last_partition_extra_size (uint64) - Should the last partition be extended? this only works for the last partition in the dos partition table, and ext filesystem

target_image_size (uint64) - The target size of the final image. The last partition will be extended to fill up this much room. I.e. if the generated image is 256MB and TargetImageSize is set to 384MB the last partition will be extended with an additional 128MB.

qemu_binary (string) - Qemu binary to use. default is determined based on image_arch. If this is an absolute path, it will be used. Otherwise, we will look for one in your PATH and finally, try to auto fetch one from https://github.com/multiarch/qemu-user-static/

disable_embedded (bool) - Do not use embedded qemu.

qemu_args ([]string) - Arguments to qemu binary. default depends on the image type. see init() function above.

qemu_required (bool) - Use qemu even when the build machine's CPU architecture matches the image's CPU architecture. Defaults to true if non-default qemu_binary or qemu_args are supplied.