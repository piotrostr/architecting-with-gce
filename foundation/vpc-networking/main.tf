resource "google_compute_instance" "mynet-us-vm" {
  name         = "mynet-us-vm"
  machine_type = "n1-standard-1"
  zone         = "us-central1-c"
  can_ip_forward = true

  network_interface {
    network = "default"
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
    network = "default"
  }

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20220719"
    }
  }
}
