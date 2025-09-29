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
  default = "netbsd"
}

source "arm-image" "openbsd" {
  image_url = "https://cdn.openbsd.org/pub/OpenBSD/7.7/arm64/install77.img"
  image_checksum = "sha256:424c8e3207df8177e854bb1ee4cefdf0cff95aa9e7e58b64e4db7b52e7d2aea1"
  output_filename = "disk_images/openbsd_77_arm64.img"
  qemu_binary     = "/usr/bin/qemu-arm-static"
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
    source      = "scripts/experiment/install_python_freebsd.sh"
    destination = "/tmp/install_python_freebsd.sh"
  }
  provisioner "file" {
    source      = "scripts/experiment/run_benchmarks.sh"  
    destination = "/tmp/run_benchmarks.sh"
  }
  provisioner "file" {
    source      = "scripts/experiment/run_benchmarks.py"  
    destination = "/tmp/run_benchmarks.py"
  }

  provisioner "shell" {
    inline = [
      "chmod +x /tmp/install_python_freebsd.sh",
      "/tmp/install_python_freebsd.sh",
      "chmod +x /tmp/run_benchmarks.sh",
      "chomod +x /tmp/run_benchmarks.py"
    ]
  }
}
