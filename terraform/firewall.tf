resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "icmp"
  }

  source_ranges = ["10.0.0.0/16"]
}
