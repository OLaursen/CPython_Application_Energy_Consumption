packer {
  required_plugins {
    arm-image = {
      version = "0.2.7"
      source  = "github.com/solo-io/arm-image"
    }
  }
}

source "arm-image" "ubuntu" {
  iso_url = "https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.5-preinstalled-server-arm64+raspi.img.xz"
  iso_checksum = "sha256:fd7687c5c9422a6c7ba4717c227bf6473fe4e0c954d5a9f664201dcecc63e822"
  output_filename = "disk_images/ubuntu-2204_arm64.img"
  image_type      = "raspberrypi"
  image_arch = "arm64"
  image_mounts = ["/boot/firmware","/"]
  chroot_mounts = [
      ["proc", "proc", "/proc"],
      ["sysfs", "sysfs", "/sys"],
      ["bind", "/dev", "/dev"],
      ["devpts", "devpts", "/dev/pts"],
      ["binfmt_misc", "binfmt_misc", "/proc/sys/fs/binfmt_misc"],
      ["bind", "/run/systemd", "/run/systemd"]
  ]
  # only needed if qemu is not installed system wide
  #qemu_binary =  "/usr/bin/qemu-aarch64-static"
}

build {
  name    = "ubuntu"
  sources = ["source.arm-image.ubuntu"]
  provisioner "shell" {
    inline = [
      "touch /boot/ssh",
    ]

  }
  # Copy installer script
  provisioner "file" {
    source      = "${path.cwd}/install_python_debian.sh"
    destination = "/tmp/install_python_debian.sh"
  }  
  provisioner "file" {
    source      = "${path.cwd}/run_benchmarks.sh"  
    destination = "/tmp/run_benchmarks.sh"
  }
  provisioner "file" {
    source      = "${path.cwd}/run_benchmarks.py"  
    destination = "/tmp/run_benchmarks.py"
  }
   # Execute installer script
  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_python_debian.sh",
      "/tmp/install_python_debian.sh"
    ]
  }
}