// instance stuff
data "google_compute_image" "debian" {
  project = "debian-cloud"
  family  = "debian-11"
}

// below is required for the proxy instance
// to be able to connect to the cloud sql
resource "google_project_service" "name" {
  service                    = "sqladmin.googleapis.com"
  disable_dependent_services = true
  disable_on_destroy         = true
}

resource "google_compute_instance" "proxy_instance_eu" {
  name         = "proxy-instance-eu"
  machine_type = "e2-small"
  zone         = "europe-west1-b"
  tags         = ["proxy-instance"]

  allow_stopping_for_update = true

  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.proxy_instance_subnetwork.name

    // block below can be left empty
    // (purpose of the block is to allow EGRESS)
    //
    // since the wordpress instances
    // will sit behind a domain likely, lets assign static IPs
    access_config {
      nat_ip = google_compute_address.static_public_ip_eu.address
    }
  }

  service_account {
    scopes = [
      "https://www.googleapis.com/auth/devstorage.full_control",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/sqlservice",
      "https://www.googleapis.com/auth/sqlservice.admin",
    ]
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.name
    }
  }
}

resource "google_compute_instance" "wordpress_instance_us" {
  name         = "wordpress-instance-us"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  tags         = ["web"]

  allow_stopping_for_update = true

  network_interface {
    network = google_compute_network.vpc.name // network does not have to be specified
    subnetwork = google_compute_subnetwork.main_instance_subnetwork.name

    access_config {
      nat_ip = google_compute_address.static_public_ip_us.address
    }
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.name
    }
  }
}
