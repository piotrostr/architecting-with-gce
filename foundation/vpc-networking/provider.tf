terraform {
  required_providers {
    google = {
      version = ">= 0.12.0"
      source  = "hashicorp/google"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}
