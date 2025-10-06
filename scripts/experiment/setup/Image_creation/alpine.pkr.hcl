packer {
  required_plugins {
    arm-image = {
      version = "0.2.7"
      source  = "github.com/solo-io/arm-image"
    }
  }
}
variable "target" {
  type    = string
  default = "alpine-pi34"
}
# This Alpine images are created for Pi's, so it may have an unforeseen advantage compared to the other operating systems. 
source "arm-image" "alpine-pi34" {
  iso_url = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/armv7/alpine-rpi-3.22.1-armv7.tar.gz"
  iso_checksum = "sha256:b5a9812bfaa6c27afba345bea73ac9e7a8767eeab39d72e326a59df146e7207d"
  output_filename = "disk_images/alpine-322_armv7.img"
  qemu_binary     = "/usr/bin/qemu-arm-static"
}

source "arm-image" "alpine-pi5" {
  iso_url = "https://dl-cdn.alpinelinux.org/alpine/v3.22/releases/aarch64/alpine-rpi-3.22.1-aarch64.tar.gz"
  iso_checksum = "sha256:182cad98919bc2838799d20e1644c1e7a4cc66125a408261bb504d2e878c629f"
  output_filename = "disk_images/alpine-322_arm64.img"
  qemu_binary     = "/usr/bin/qemu-aarch64-static"
}

build {
  name    = var.target
  sources = [
    "source.arm-image.${var.target}"
  ]
  provisioner "shell" {
    inline = [" date | sudo tee /etc/motd"]
  }

  provisioner "file" {
    source      = "/workspace/experiment/install_python_alpine.sh"
    destination = "/tmp/install_python_alpine.sh"
  }
    provisioner "file" {
    source      = "/workspace/experiment/run_benchmarks.sh"  
    destination = "/tmp/run_benchmarks.sh"
  }
  provisioner "file" {
    source      = "/workspace/experiment/run_benchmarks.py"  
    destination = "/tmp/run_benchmarks.py"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_python_alpine.sh",
      "/tmp/install_python_alpine.sh"
    ]
  }
}
