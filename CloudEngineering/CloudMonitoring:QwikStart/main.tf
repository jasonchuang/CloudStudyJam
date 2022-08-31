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

variable "gcp_zone" {
  type        = string
  description = "GCP Zone."
}

variable "gcp_region" {
  type        = string
  description = "GCP Region."
}

provider "google" {
  # Configuration options
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

resource "google_compute_instance" "lamp-1-vm" {
  name         = "lamp-1-vm"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  #  zone         = "us-west1-b"
  zone         = "${var.gcp_zone}"
  machine_type = "n1-standard-2"

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }

  tags = ["http", "http-server"]
  #  metadata_startup_script = "echo hi > /test.txt"
  metadata_startup_script = <<SCRIPT
    sudo service apache2 restart
    curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
    sudo bash add-google-cloud-ops-agent-repo.sh --also-install
    sudo apt-get update
    sudo apt-get install apache2 php7.0
    SCRIPT
}

