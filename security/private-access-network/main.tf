resource "google_compute_network" "base_network" {
  name = "base-network"
  auto_create_subnetworks = true
}

resource "google_compute_subnetwork" "subnet_that_can_gcp" {
  name = "subnet-that-can-gcp"
  ip_cidr_range = "10.0.0.0/12"
  network = google_compute_network.base_network.name
  // making the below true allows the subnet to call GCP services without service acc
  private_ip_google_access = true
}
