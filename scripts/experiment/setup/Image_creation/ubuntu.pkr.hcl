packer {
  required_plugins {
    arm-image = {
      version = "0.2.7"
      source  = "github.com/solo-io/arm-image"
    }
  }
}

source "arm-image" "ubuntu" {
  iso_url = "https://cdimage.ubuntu.com/releases/22.04/release/ubuntu-22.04.5-preinstalled-desktop-arm64+raspi.img.xz"
  iso_checksum = "sha256:74764944dd4a96bdddd30cf1ffc133ecbe5ebb1d1f2eaa34cd5f8fbb57211c86"
  output_filename = "ubuntu2204_image"
  # Due to the architecture of the pi, qemu needs to be externally used requiring the binary. 
  qemu_binary     = "/usr/bin/qemu-aarch64-static"
}


build {
  name    = "ubuntu"
  sources = [
    "source.arm-image.ubuntu"
  ]
}