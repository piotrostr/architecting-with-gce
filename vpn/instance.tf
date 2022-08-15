resource "google_compute_instance" "server_1" {
  name         = "server-1"
  machine_type = "n1-standard-1"
  zone         = "us-central1-a"
  tags         = ["ssh-and-icmp"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.network_1.name
    subnetwork = google_compute_subnetwork.subnet_1.name

    access_config {
      // assign non-static public IP
    }
  }
}

resource "google_compute_instance" "server_2" {
  name         = "server-2"
  machine_type = "n1-standard-2"
  zone         = "europe-west1-b"
  tags         = ["ssh-and-icmp"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.network_2.name
    subnetwork = google_compute_subnetwork.subnet_2.name

    access_config {
      // assign non-static public IP
    }
  }
}
