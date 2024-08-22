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
  name         = "terraform-instance"
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
    ssh-keys = "user:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGlcCuQc4RWSFnbkDd/pOUcNM7Dheq9wouceYxRmborBVX+HkuAeyD0COgz1ouwNluQ60hLgWYLyZ/ZuHVw41K6W/ySf4Qb2pZG3NQLFHIGAxLtsGc+/6OlK2i5kSz6dKUdPdHfHKzMciYN0Qa8h+o6DmwNvXh+DR7OvY8qTA+C2K1PaUvoxQSxgDN470sywyWLV9EvMS4wXXWdru0AdLuhyHpe1thkvsHlDefIHX8GW2iue/L2waQVKF/SQuHL5Jew8mP4CbZA52hsXWnpUWtndw9WEKLLvtmj/IsDfneH+aizVHjsRyf9w3Fe6wNvMd1eO0v8wKRbt6H1QT5ztqR"
  }
}

output "instance_ids" {
  description = "The IDs of the Google Compute instances"
  value       = google_compute_instance.vm_instance.id
}

output "ip" {
  value = google_compute_instance.vm_instance.network_interface.0.network_ip
}

output "public_ip" {
  value = google_compute_instance.vm_instance.network_interface.0.access_config[0].nat_ip
}