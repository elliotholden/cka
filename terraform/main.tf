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