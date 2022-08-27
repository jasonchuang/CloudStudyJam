terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.33.0"
    }
  }
}

provider "google" {
  # Configuration options
  project     = "kumo-cicd"
  region      = "us-central1"
}


resource "google_project_iam_policy" "project" {
  project     = "kumo-cicd"
  policy_data = data.google_iam_policy.admin.policy_data
}

data "google_iam_policy" "admin" {
  binding {
    role = "roles/storage.objectViewer"

    members = [
      "user:jane@example.com",
    ]
  }
}

