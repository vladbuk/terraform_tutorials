terraform {
  required_providers {
    virtualbox = {
      source  = "terra-farm/virtualbox"
      version = "0.2.2-alpha.1"
    }
  }
}

provider "virtualbox" {}

resource "virtualbox_vm" "ubuntu" {
  name   = "test-ubuntu-server"
  image  = "https://cloud-images.ubuntu.com/releases/20.04/release/ubuntu-20.04-server-cloudimg-amd64.ova"
  cpus   = 2
  memory = "2048 mib"

  network_adapter {
    type           = "nat"
    host_interface = "vboxnet0"
  }
}
