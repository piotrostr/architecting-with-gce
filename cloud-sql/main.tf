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
  name = "static-public-ip-us"
  region = "us-central1"
  address_type = "EXTERNAL"
}

// cool thing is that the addresses can be defined in the subnetwork
// need to match the CIDR, but a lot of flexibility
resource "google_compute_address" "static_public_ip_eu" {
  name = "static-public-ip-eu"
  region = "europe-west1"
  address_type = "EXTERNAL" // or "INTERNAL", and specify the subnetwork
}

resource "google_compute_firewall" "web_rules" {
  project     = var.project
  name        = "web-rules"
  network     = google_compute_network.vpc.name
  description = "Creates INGRESS firewall rule targeting tagged instances"
  source_ranges = [ "0.0.0.0/0" ]

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

    // block below can be left empty
    // (purpose of the block is to allow EGRESS)
    //
    // since the wordpress instances
    // will sit behind a domain likely, lets assign static IPs
    access_config {
      nat_ip = google_compute_address.static_public_ip_eu.address
    }

    // include the following to also get a public IPv6 address
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
