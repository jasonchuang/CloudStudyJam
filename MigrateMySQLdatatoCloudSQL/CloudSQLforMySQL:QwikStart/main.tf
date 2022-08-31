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

resource "google_sql_database_instance" "main" {
  project      = "${var.gcp_project}"
  zone         = "${var.gcp_zone}"
  name             = "myinstance"
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
  name     = "guestbook"
  instance = google_sql_database_instance.main.name
}

