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
  project   = "${var.gcp_project}"
  region    = "${var.gcp_region}"
  zone      = "${var.gcp_zone}"
}


# VPC * 2
resource "google_compute_network" "vpc_managementnet" {
  name                    = "managementnet"
  auto_create_subnetworks = false
  #  mtu                  = 1460
}
resource "google_compute_network" "vpc_privatenet" {
  name                    = "privatenet"
  auto_create_subnetworks = false
  #  mtu                  = 1460
}

# subnet * 3
resource "google_compute_subnetwork" "managementsubnet-us" {
  name          = "managementsubnet-us"
  ip_cidr_range = "10.130.0.0/20"
  region        = "us-east1"
  network       = google_compute_network.vpc_managementnet.id
}

resource "google_compute_subnetwork" "privatesubnet-us" {
  name          = "privatesubnet-us"
  ip_cidr_range = "172.16.0.0/24"
  region        = "us-east1"
  network       = google_compute_network.vpc_privatenet.id
}

resource "google_compute_subnetwork" "privatesubnet-eu" {
  name          = "privatesubnet-eu"
  ip_cidr_range = "172.20.0.0/20"
  region        = "europe-west4"
  network       = google_compute_network.vpc_privatenet.id
}

# fw for managementnet
resource "google_compute_firewall" "managementnet-allow-icmp-ssh-rdp" {
  name       = "managementnet-allow-icmp-ssh-rdp"
  network    = google_compute_network.vpc_managementnet.id

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

# fw for privatenet
resource "google_compute_firewall" "privatenet-allow-icmp-ssh-rdp" {
  name       = "privatenet-allow-icmp-ssh-rdp"
  network    = google_compute_network.vpc_privatenet.id
  priority   = 1000
  direction  = "INGRESS"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "managementnet-us-vm" {
  name         = "managementnet-us-vm"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  zone         = "us-east1-c"
  machine_type = "e2-micro"

  network_interface {
    network = "managementnet"
    subnetwork = "managementsubnet-us"
  }
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
  }
}

resource "google_compute_instance" "vm_appliance" {
  name         = "vm-appliance"
  zone         = "us-east1-c"
  machine_type = "e2-standard-4"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "privatenet"
    subnetwork = "privatesubnet-us"
  }
  network_interface {
    network = "managementnet"
    subnetwork = "managementsubnet-us"
  }
  network_interface {
    network = "mynetwork"
    subnetwork = "mynetwork"
  }
}

