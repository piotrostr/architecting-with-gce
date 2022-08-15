# vpc

locals {
  machine_type = "n1-standard-1"
  image = "debian-cloud/debian-11"
}

resource "google_compute_network" "vpc" {
  name                    = "vpc"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "firewall" {
  name          = "web-ssh-firewall"
  target_tags   = ["web"]
  source_ranges = ["0.0.0.0/0"]
  network       = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = [22, 80, 8080]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_instance" "instance_us" {
  name = "instance-us"
  zone = "us-central1-a"
  tags = ["web"]
  machine_type = local.machine_type

  boot_disk {
    initialize_params {
      image = local.image
    }
  }

  network_interface {
    network = google_compute_network.vpc.name

    access_config {}
  }
}

resource "google_compute_instance" "instance_eu" {
  name = "instance-eu"
  zone = "europe-west1-b"
  machine_type = local.machine_type
  tags = ["web"]

  boot_disk {
    initialize_params {
      image = local.image
    }
  }

  network_interface {
    network = google_compute_network.vpc.name

    access_config {}
  }
}
