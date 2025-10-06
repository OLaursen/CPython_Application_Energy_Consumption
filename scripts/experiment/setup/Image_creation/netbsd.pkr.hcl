#NetBSD 9 is supposed to work with RPI 3 and 4. While NetBSD Current supports RPI 5. https://wiki.netbsd.org/ports/evbarm/raspberry_pi/
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

# This Alpine images are created for Pi's, so it may have an unforeseen advantage compared to the other operating systems. 
source "arm-image" "netbsd" {
  iso_url = "https://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-10/latest/evbarm-aarch64/binary/gzimg/arm64.img.gz"
  iso_checksum = "sha256:38cc4e9245a88fd41368a4533b5c09e3e51d1b6539c8b3fbb65f31118fccffd8"
  output_filename = "disk_images/netbsd_10_arm64.img"
  qemu_binary     = "/usr/bin/qemu-arm-static"
}
# source "arm-image" "freebsd-pi45" {
#   image_url = "https://nycdn.netbsd.org/pub/NetBSD-daily/netbsd-10/latest/evbarm-aarch64/binary/gzimg/arm64.img.gz"
#   image_checksum = "sha256:38cc4e9245a88fd41368a4533b5c09e3e51d1b6539c8b3fbb65f31118fccffd8"
#   output_filename = "disk_images/netbsd_10_arm64.img"
#   qemu_binary     = "/usr/bin/qemu-arm-static"
# }

build {
  name    = var.target
  sources = [
    "source.arm-image.${var.target}"
  ]
  provisioner "shell" {
    inline = [" date | sudo tee /etc/motd"]
  }

  provisioner "file" {
    source      = "/workspace/experiment/install_python_freebsd.sh"
    destination = "/tmp/install_python_freebsd.sh"
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
      "chmod +x /tmp/install_python_freebsd.sh",
      "/tmp/install_python_freebsd.sh",
      "chmod +x /tmp/run_benchmarks.sh",
      "chomod +x /tmp/run_benchmarks.py"
    ]
  }
}