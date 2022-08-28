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

resource "google_sql_database_instance" "main" {
  name             = "qwiklabs-demo"
  database_version = "MYSQL_5_7"
  region           = "us-central1"
  password         = "mypassword"

  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "database" {
  name     = "bike"
  instance = google_sql_database_instance.main.name
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

resource "google_storage_bucket_object" "bq_csv" {
  name          = "bq.csv"
  source        = "./bq.csv"
  bucket        = google_storage_bucket.static-site.name
}

