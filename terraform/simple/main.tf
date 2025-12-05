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
  project = "k8s-simple-480315"
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
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuvHz4ovrcF3Uj2B9X7Jwgt9VV1wDR6KNRR433zJGx4"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/k8s-simple-480315/regions/us-east1/subnetworks/default"
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
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuvHz4ovrcF3Uj2B9X7Jwgt9VV1wDR6KNRR433zJGx4"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/k8s-simple-480315/regions/us-east1/subnetworks/default"
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
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuvHz4ovrcF3Uj2B9X7Jwgt9VV1wDR6KNRR433zJGx4"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/k8s-simple-480315/regions/us-east1/subnetworks/default"
  }
}

output "all_instance_ips" {
  value = {
    control_node = google_compute_instance.c1.network_interface[0].access_config[0].nat_ip
    worker_1     = google_compute_instance.w1.network_interface[0].access_config[0].nat_ip
    worker_2     = google_compute_instance.w2.network_interface[0].access_config[0].nat_ip
  }
  description = "All instance public IP addresses"
}
