resource "google_compute_network" "mynetwork" {
  name = "mynetwork"
}

resource "google_compute_firewall" "mynetwork" {
  name = "web"
  network = google_compute_network.mynetwork.name
  source_tags = ["web"]

  allow {
    protocol = "icmp"
  }

  allow {
    ports = [ "80", "22", "443" ]
    protocol = "tcp"
  }
}

resource "google_compute_instance" "mynet-us-vm" {
  name         = "mynet-us-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"
  can_ip_forward = true

  network_interface {
    network = google_compute_network.mynetwork.name
  }

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20220719"
    }
  }
}

resource "google_compute_instance" "mynet-eu-vm" {
  name         = "mynet-eu-vm"
  machine_type = "n1-standard-1"
  zone         = "europe-west1-c"
  can_ip_forward = true

  network_interface {
    network = google_compute_network.mynetwork.name
  }

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20220719"
    }
  }
}
