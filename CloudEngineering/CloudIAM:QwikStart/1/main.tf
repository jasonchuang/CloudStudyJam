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
}

resource "google_storage_bucket_object" "sample_txt" {
  name          = "sample.txt"
  source        = "./sample.txt"
  bucket        = random_string.random_bucket_name.result
}
