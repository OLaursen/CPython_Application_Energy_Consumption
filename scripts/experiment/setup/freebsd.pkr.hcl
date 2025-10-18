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
  default = "freebsd-pi34"
}

# This Alpine images are created for Pi's, so it may have an unforeseen advantage compared to the other operating systems. 
source "arm-image" "freebsd-pi34" {
  iso_url = "https://download.freebsd.org/releases/arm64/aarch64/ISO-IMAGES/14.3/FreeBSD-14.3-RELEASE-arm64-aarch64-RPI.img.xz"
  iso_checksum = "sha256:d9850012811a5fdf07e2585f1ba13f38c920e6fa5d6e992b688f4913912e021b"
  output_filename = "disk_images/freebsd-143_arm64.img"
  
  #qemu_binary     = "/usr/bin/qemu-arm-static"
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
    source      = "${path.cwd}/python_installers/install_python_freebsd.sh"
    destination = "/tmp/install_python_freebsd.sh"
  }
  provisioner "file" {
    source      = "${path.cwd}/run_benchmarks.sh"  
    destination = "/tmp/run_benchmarks.sh"
  }
  provisioner "file" {
    source      = "${path.cwd}/run_benchmarks.py"  
    destination = "/tmp/run_benchmarks.py"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_python_freebsd.sh",
      "/tmp/install_python_freebsd.sh",
    ]
  }
}
