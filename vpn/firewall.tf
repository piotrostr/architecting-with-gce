resource "google_compute_firewall" "firewall_1" {
  name          = "allow-ssh-and-icmp-1"
  description   = "Allow SSH and ICMP"
  network       = google_compute_network.network_1.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-and-icmp"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "firewall_2" {
  name          = "allow-ssh-and-icmp-2"
  description   = "Allow SSH and ICMP"
  network       = google_compute_network.network_2.name
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-and-icmp"]

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }
}
