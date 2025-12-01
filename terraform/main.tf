terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

provider "google" {
  project = var.project 
  region  = var.region
  zone    = var.zone
}

resource "google_compute_instance" "c1" {

  name            = "control-1"
  hostname        = "c1.cka"
  machine_type    = "e2-small"
  can_ip_forward  = true
  tags            = ["http-server"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20251121"
      size  = 20
      type  = "pd-ssd"
    }
  }

  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys        = "${var.ssh-public-key-1}, ${var.ssh-public-key-2}"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/${var.project}/regions/us-east1/subnetworks/${var.subnet}"
  }

}

resource "google_compute_instance" "w1" {

  name            = "worker-1"
  hostname        = "w1.cka"
  machine_type    = "e2-small"
  can_ip_forward  = true
  tags            = ["http-server"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20251121"
      size  = 20
      type  = "pd-ssd"
    }
  }

  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys        = "${var.ssh-public-key-1}, ${var.ssh-public-key-2}'"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/${var.project}/regions/us-east1/subnetworks/${var.subnet}"
  }

}

resource "google_compute_instance" "w2" {

  name            = "worker-2"
  hostname        = "w2.cka"
  machine_type    = "e2-small"
  can_ip_forward  = true
  tags            = ["http-server"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20251121"
      size  = 20
      type  = "pd-ssd"
    }
  }


  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys        = "${var.ssh-public-key-1}, ${var.ssh-public-key-2}"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/${var.project}/regions/us-east1/subnetworks/${var.subnet}"
  }

}
