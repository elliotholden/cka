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
  project = "confidential-computing-481417"
  region  = "us-east1"
  zone    = "us-east1-b"
}

resource "google_compute_instance" "coco_node" {

  name            = "coco-node"
  hostname        = "anjuna.elliotmywebguycom"
  machine_type    = "n2d-standard-2"
  can_ip_forward  = true
  tags            = ["http-server","https-server","k8s-ports"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/ubuntu-2404-noble-amd64-v20251121"
      size  = 20
      type  = "pd-ssd"
    }
  }

  # CRITICAL: Enable confidential computing
  confidential_instance_config {
    enable_confidential_compute = true
  }
  
  # Enable nested virtualization if needed for Kata Containers
  # advanced_machine_features {
  #   enable_nested_virtualization = true
  # }

  metadata = {
    enable-osconfig = "TRUE"
    ssh-keys        = "elliot:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuvHz4ovrcF3Uj2B9X7Jwgt9VV1wDR6KNRR433zJGx4\nemwg:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuvHz4ovrcF3Uj2B9X7Jwgt9VV1wDR6KNRR433zJGx4"
  }

  network_interface {
    access_config {}
    subnetwork  = "projects/confidential-computing-481417/regions/us-east1/subnetworks/default"
  }

}

resource "google_compute_firewall" "k8s_ports" {
  name    = "allow-k8s-ports"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["6443", "2379-2380", "10250-10259", "30000-32767"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["k8s-ports"]
}

output "all_instance_ips" {
  value = {
    node1 = google_compute_instance.coco_node.network_interface[0].access_config[0].nat_ip
  }
  description = "All instance public IP addresses"
}
