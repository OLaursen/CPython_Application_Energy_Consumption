packer {
  required_plugins {
    arm-image = {
      version = "0.2.7"
      source  = "github.com/solo-io/arm-image"
    }
  }
}

source "arm-image" "manjaro" {
  iso_url = "https://github.com/manjaro-arm/generic-images/releases/download/23.02/Manjaro-ARM-minimal-generic-23.02.img.xz"
  iso_checksum = "sha256:7a496df5a18e7657ff5ae289af2044d74a5ba7ff"
  output_filename = "disk_images/manjaro-minimal_arm64.img"
  # Due to the architecture of the pi, qemu needs to be externally used requiring the binary. 
  qemu_binary     = "/usr/bin/qemu-aarch64-static"
}

build {
  name    = "manjaro"
  sources = [
    "source.arm-image.manjaro"
  ]
  provisioner "shell" {
    inline = [" date | sudo tee /etc/motd"]
  }
  #Copy installer script
  provisioner "file" {
    source      = "scripts/experiment/setup/Image_creation/install_python_arch.sh"
    destination = "/tmp/install_python_arch.sh"
  }  
  provisioner "file" {
    source      = "scripts/experiment/run_benchmarks.sh"  
    destination = "/tmp/run_benchmarks.sh"
  }
  provisioner "file" {
    source      = "scripts/experiment/run_benchmarks.py"  
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
