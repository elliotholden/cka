variable "project" {
  description = "The GCP project ID"
  type        = string
  default     = "cka-lab-479912"
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-east1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-east1-b"
}

variable "subnet" {
  description = "The GCP subnet"
  type        = string
  default     = "kubernetes-subnet"
}

variable "ssh-public-key" {
  description = "SSH public key"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuvHz4ovrcF3Uj2B9X7Jwgt9VV1wDR6KNRR433zJGx4 elliot"
}
