resource "google_compute_network" "course_network" {
  name                    = "course-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "course_subnetwork" {
  name          = "course-subnetwork"
  ip_cidr_range = "10.130.0.0/20"
  region        = var.region
  network       = google_compute_network.course_network.id
}

resource "google_compute_firewall" "web_ssh_firewall" {
  name        = "web-ssh"
  network     = google_compute_network.course_network.id
  source_tags = ["web"]

  allow {
    protocol = "icmp"
  }

  allow {
    ports    = ["80", "22", "443"]
    protocol = "tcp"
  }
}

resource "google_compute_instance" "course_instance" {
  name           = "course-instance"
  machine_type   = "n1-standard-1"
  zone           = "${var.region}-c"
  can_ip_forward = true

  network_interface {
    network    = google_compute_network.course_network.id
    subnetwork = google_compute_subnetwork.course_subnetwork.id
  }

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20220719"
    }
  }
}
