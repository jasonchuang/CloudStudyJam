terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.33.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.3.2"
    }

  }
}

variable "gcp_project" {
  type        = string
  description = "GCP Project."
}

variable "gcp_region" {
  type        = string
  description = "GCP Region."
}

variable "gcp_zone" {
  type        = string
  description = "GCP Zone."
}

provider "google" {
  # Configuration options
  project   = "${var.gcp_project}"
  region    = "${var.gcp_region}"
  zone      = "${var.gcp_zone}"
}

resource "google_compute_instance" "privatenet-us-vm" {
  name         = "privatenet-us-vm"
  zone         = "us-east1-c"
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "privatenet"
    subnetwork = "privatesubnet-us"
    access_config {
      // Ephemeral public IP
    }
  }
}
