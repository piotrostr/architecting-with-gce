# network stuff
resource "google_compute_network" "vpc" {
  name                    = "cloud-sql-course-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "proxy_instance_subnetwork" {
  name          = "proxy-instance-subnetwork"
  network       = google_compute_network.vpc.name
  region        = "europe-west1"
  ip_cidr_range = "10.132.0.0/20" // the CIDRs are predefined per region!
}

resource "google_compute_subnetwork" "main_instance_subnetwork" {
  name          = "main-instance-subnetwork"
  network       = google_compute_network.vpc.name
  region        = "us-central1"
  ip_cidr_range = "10.128.0.0/20" // all CIDRs can be found below
  // https://cloud.google.com/vpc/docs/subnets#ip-ranges
}

// allocate a static IP for each of the instances
resource "google_compute_address" "static_public_ip_us" {
  name         = "static-public-ip-us"
  region       = "us-central1"
  address_type = "EXTERNAL"
}

// cool thing is that the addresses can be defined in the subnetwork
// need to match the CIDR, but a lot of flexibility
resource "google_compute_address" "static_public_ip_eu" {
  name         = "static-public-ip-eu"
  region       = "europe-west1"
  address_type = "EXTERNAL" // or "INTERNAL", and specify the subnetwork
}

resource "google_compute_firewall" "proxy_firewall" {
  project       = var.project
  name          = "proxy-firewall"
  description   = "Opens the 3306 port and allows SSH"
  network       = google_compute_network.vpc.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["proxy-instance"]

  // allow pings as well
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "3306"]
  }
}

resource "google_compute_firewall" "web_rules" {
  project       = var.project
  name          = "web-rules"
  description   = "Creates INGRESS firewall rule targeting tagged instances"
  network       = google_compute_network.vpc.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]

  // allow pings as well
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "443"]
  }
}
