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
provider "google" {
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}


resource "google_notebooks_instance" "instance" {
  name = "notebooks-instance"
  location = "us-west1-a"
  machine_type = "e2-medium"

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-ent-2-3-cpu"
  }
}




