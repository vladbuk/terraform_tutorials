terraform {
  cloud {
    organization = "vladbuk-inc"
    workspaces {
      name = "learning-gcp"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "kuber-430607"
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_firewall" "default" {
  name    = "default-allow-ssh-http-https"
  network = google_compute_network.vpc_network.name
  #   network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "vm_instance" {
  count        = 2
  name         = "terraform-instance-${count.index}"
  machine_type = "f1-micro"
  tags         = ["web", "dev"]

  boot_disk {
    initialize_params {
      image = "cos-cloud/cos-stable"
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  metadata = {
    ssh-keys = "user:${var.public_key}"
  }
}

output "instance_ids" {
  description = "The IDs of the Google Compute instances"
  value       = google_compute_instance.vm_instance[*].id
}

output "ip" {
  value = google_compute_instance.vm_instance[*].network_interface.0.network_ip
}

output "public_ip" {
  value = google_compute_instance.vm_instance[*].network_interface.0.access_config[0].nat_ip
}