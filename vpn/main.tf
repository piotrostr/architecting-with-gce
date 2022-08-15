resource "google_compute_network" "network_1" {
  name                    = "network-1"
  auto_create_subnetworks = false
}

resource "google_compute_network" "network_2" {
  name                    = "network-2"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet_1" {
  name          = "subnet-1"
  network       = google_compute_network.network_1.name
  region        = "us-central1"
  ip_cidr_range = "10.128.0.0/9"
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "subnet-2"
  network       = google_compute_network.network_2.name
  region        = "europe-west1"
  ip_cidr_range = "10.132.0.0/9"
}

resource "google_compute_firewall" "firewall_1" {
  name          = "allow-ssh-and-icmp"
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
  name          = "allow-ssh-and-icmp"
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
  zone         = "us-central1-a"
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

resource "google_compute_address" "static_address_1" {
  name = "address-1"
}

resource "google_compute_address" "static_address_2" {
  name = "address-2"
}

resource "google_compute_vpn_gateway" "vpn_gateway_1" {
  name    = "vpn-1"
  network = google_compute_network.network_1.name
  region  = "us-central1"
}

resource "google_compute_vpn_tunnel" "tunnel_1to2" {
  name                    = "tunnel-between-networks"
  shared_secret           = "gcprocks"
  vpn_gateway             = google_compute_vpn_gateway.vpn_gateway_1.name
  remote_traffic_selector = ["10.128.0.0/24"]
  peer_ip                 = google_compute_address.static_address_2.address
}
