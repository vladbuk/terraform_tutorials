terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }
}

provider "google" {
  project = "kuber-430607"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}
