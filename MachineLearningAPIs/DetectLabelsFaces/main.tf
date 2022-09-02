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

resource "random_string" "random_bucket_name" {
  length           = 12
  upper            = false
  special          = false
}

output "random_bucket_string" {
  value = random_string.random_bucket_name.result
}

resource "google_storage_bucket" "static-site" {
  name          = random_string.random_bucket_name.result
  location      = "US"

  uniform_bucket_level_access = false
}

resource "google_storage_bucket_object" "sample_txt" {
  name          = "donuts.png"
  source        = "./donuts.png"
  bucket        = google_storage_bucket.static-site.name
}


resource "google_storage_bucket_object" "selfie" {
  name          = "selfie.png "
  source        = "./selfie.png "
  bucket        = google_storage_bucket.static-site.name
}
