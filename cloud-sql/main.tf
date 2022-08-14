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

resource "google_compute_firewall" "web_rules" {
  project     = var.project
  name        = "web-rules"
  network     = google_compute_network.vpc.name
  description = "Creates firewall rule targeting tagged instances"

  // allow pings as well
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "8080", "443"]
  }
  target_tags = ["web"]
}

// instance stuff
data "google_compute_image" "debian" {
  project = "debian-cloud"
  family  = "debian-11"
}

resource "google_compute_instance" "wordpress_instance_eu" {
  name         = "wordpress-instance-eu"
  machine_type = "e2-small"
  zone         = "europe-west1-b"
  tags         = ["web"]

  network_interface {
    subnetwork = google_compute_subnetwork.proxy_instance_subnetwork.name

    // include the following to get a public IP address
    ipv6_access_config {
      network_tier = "PREMIUM"
    }
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

  network_interface {
    subnetwork = google_compute_subnetwork.main_instance_subnetwork.name
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian.name
    }
  }
}


// cloud sql stuff
resource "google_sql_database_instance" "db_instance" {
  database_version = "POSTGRES_14"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "cloud_sql" {
  name     = "cloud-sql-course-database"
  instance = google_sql_database_instance.db_instance.name
}
