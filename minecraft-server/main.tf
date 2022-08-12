resource "google_compute_network" "mynetwork" {
  name                    = "mynetwork"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "mynetwork" {
  name          = "mc"
  network       = google_compute_network.mynetwork.name
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "icmp"
  }

  allow {
    ports    = ["22", "25565"]
    protocol = "tcp"
  }
}

resource "google_compute_instance_template" "template" {
  region       = var.region
  name         = "mc-server"
  machine_type = "n1-standard-1"

  // network interface != network
  // network interface is like a wi-fi modem to a laptop
  network_interface {
    network = google_compute_network.mynetwork.id

    access_config {
      // this block is crucial, otherwise no public IP
    }
  }

  // add a base image
  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  // add the second disk for the data drive
  disk {
    boot         = false
    auto_delete  = true
    disk_type    = "pd-ssd"
    disk_size_gb = 50
    type         = "PERSISTENT"
  }
}

module "vm_compute_instance" {
  source  = "terraform-google-modules/vm/google//modules/compute_instance"
  version = "7.8.0"

  zone              = "us-central1-a"
  region            = var.region
  instance_template = google_compute_instance_template.template.id
}
