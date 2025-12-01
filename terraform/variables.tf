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

variable "ssh-public-key-1" {
  description = "SSH public key 1"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOuvHz4ovrcF3Uj2B9X7Jwgt9VV1wDR6KNRR433zJGx4 elliot"
}

variable "ssh-public-key-2" {
  description = "SSH public key 2"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC2icGmmoZi1OgKVS37SIquk0MO+FWtZBjxRK+tLKxd5h3hacuqZ4SkWWRrd1K2nRO3uazKZASEUo6ksvDDqpviQZOeVsA/9Q0JYXNSB9IRahebgId12beII+kbEDl57wb9czb8K4dMCuU0Rn8mqmaBjM1ruPGaocO7oGyGJEgEUEMJwiKHzz0EfK2QcwDVQ2IExcOAiS3g2SP/pSVkqZjjnwXoO56d6yHAGGp/XpzHu9OW03KNnSlgi9kuQSSwetzTCOUDRbXG0Z1Is4AAdKrSzQ2RkUIVZalUtRAeUSjiWMD4lu4yEdRnQE36Arz3us11CowUb+m44d2u4Qm088Ul elliot"
}
