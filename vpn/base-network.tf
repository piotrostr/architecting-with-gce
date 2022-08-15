resource "google_compute_network" "network_1" {
  name                    = "network-1"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network_2" {
  name                    = "network-2"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-1"
  network       = google_compute_network.network_1.name
  region        = "us-central1"
  ip_cidr_range = "10.128.0.0/20"
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "subnet-2"
  network       = google_compute_network.network_2.name
  region        = "europe-west1"
  ip_cidr_range = "10.132.0.0/20"
}
