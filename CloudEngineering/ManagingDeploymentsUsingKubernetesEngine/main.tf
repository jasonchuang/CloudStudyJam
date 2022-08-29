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

provider "google" {
  # Configuration options
  project     = "kumo-cicd"
  region      = "us-central1"
}


variable "project_id" {
  type = string
}

variable "zone" {
  type = string
}


resource "google_container_cluster" "bootcamp" {
  name     = "bootcamp"
  project  = "${var.project_id}"
  location = "${var.zone}"

  remove_default_node_pool = true
  initial_node_count       = 3
}

resource "google_container_node_pool" "bootcamp_np" {
  name       = "bootcamp_np"
  location   = "${var.zone}"
  cluster    = google_container_cluster.bootcamp.name
  node_count = 3

  node_config {
    preemptible  = true
    machine_type = "e2-small"

    oauth_scopes    = [
      "https://www.googleapis.com/auth/projecthosting,storage-rw"
    ]
  }
}

