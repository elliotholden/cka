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
  project = "$(gcloud config get-value project)"
  region  = "us-east1"
  zone    = "us-east1-a"
}

resource "google_compute_instance" "control-1" {
  boot_disk {
    auto_delete = true
    device_name = "control-1"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20251121"
      size  = 20
      type  = "pd-ssd"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = true
  deletion_protection = false
  enable_display      = false
  hostname            = "c1.cka"

  machine_type = "e2-small"

  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2NTmSuzXNu6PKMyTQG5j7BFYVuQwKMv/OetIHfkQvm elliot"
  }

  name = "control-1"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/long-classifier-471101-r7/regions/us-east1/subnetworks/kubernetes-subnet"
  }

  tags = ["http-server"]
  zone = "us-east1-b"
}

resource "google_compute_instance" "worker-1" {
  boot_disk {
    auto_delete = true
    device_name = "worker-1"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20251121"
      size  = 20
      type  = "pd-ssd"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = true
  deletion_protection = false
  enable_display      = false
  hostname            = "w1.cka"

  machine_type = "e2-small"

  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2NTmSuzXNu6PKMyTQG5j7BFYVuQwKMv/OetIHfkQvm elliot"
  }

  name = "worker-1"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/long-classifier-471101-r7/regions/us-east1/subnetworks/kubernetes-subnet"
  }

  tags = ["http-server"]
  zone = "us-east1-b"
}

resource "google_compute_instance" "worker-2" {
  boot_disk {
    auto_delete = true
    device_name = "worker-2"

    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20251121"
      size  = 20
      type  = "pd-ssd"
    }

    mode = "READ_WRITE"
  }

  can_ip_forward      = true
  deletion_protection = false
  enable_display      = false
  hostname            = "w2.cka"

  machine_type = "e2-small"

  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2NTmSuzXNu6PKMyTQG5j7BFYVuQwKMv/OetIHfkQvm elliot"
  }

  name = "worker-2"

  network_interface {
    access_config {
      network_tier = "PREMIUM"
    }

    queue_count = 0
    stack_type  = "IPV4_ONLY"
    subnetwork  = "projects/long-classifier-471101-r7/regions/us-east1/subnetworks/kubernetes-subnet"
  }

  tags = ["http-server"]
  zone = "us-east1-b"
}
