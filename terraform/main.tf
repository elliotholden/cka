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
  project = "cka-lab-479912"
  region  = "us-east1"
  zone    = "us-east1-b"
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
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2NTmSuzXNu6PKMyTQG5j7BFYVuQwKMv/OetIHfkQvm elliot"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/long-classifier-471101-r7/regions/us-east1/subnetworks/kubernetes-subnet"
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
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2NTmSuzXNu6PKMyTQG5j7BFYVuQwKMv/OetIHfkQvm elliot"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/long-classifier-471101-r7/regions/us-east1/subnetworks/kubernetes-subnet"
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
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2NTmSuzXNu6PKMyTQG5j7BFYVuQwKMv/OetIHfkQvm elliot"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/long-classifier-471101-r7/regions/us-east1/subnetworks/kubernetes-subnet"
  }

}
