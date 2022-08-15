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
  ip_cidr_range = "10.128.0.0/20"
}

resource "google_compute_subnetwork" "subnet_2" {
  name          = "subnet-2"
  network       = google_compute_network.network_2.name
  region        = "europe-west1"
  ip_cidr_range = "10.132.0.0/20"
}

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

resource "google_compute_address" "static_address_1" {
  name = "address-1"
}

resource "google_compute_address" "static_address_2" {
  name = "address-2"
}

resource "google_compute_address" "vpn_static_address" {
  name = "vpn-static-address"
}

resource "google_compute_vpn_gateway" "target_gateway" {
  name    = "vpn-1"
  network = google_compute_network.network_1.name
}

resource "google_compute_forwarding_rule" "fr_esp" {
  name        = "fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_static_address.address
  // the target has to be using `id`, not `name` or `self_link`
  target = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp500" {
  name        = "fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_static_address.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_forwarding_rule" "fr_udp4500" {
  name        = "fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_static_address.address
  target      = google_compute_vpn_gateway.target_gateway.id
}

resource "google_compute_route" "route_1" {
  name                = "route-1"
  network             = google_compute_network.network_1.name
  dest_range          = "0.0.0.0/0"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel_1to2.id
}

resource "google_compute_vpn_tunnel" "tunnel_1to2" {
  name                    = "tunnel-between-networks"
  shared_secret           = "gcprocks"
  target_vpn_gateway      = google_compute_vpn_gateway.target_gateway.id
  remote_traffic_selector = ["10.128.0.0/20"]  // network_2 (eu)
  peer_ip                 = google_compute_address.static_address_2.address
  local_traffic_selector  = ["10.132.0.0/20"]  // network_1 (us)

  depends_on = [
    // the rules below are required to be in deps and to be created
    google_compute_forwarding_rule.fr_esp,
    google_compute_forwarding_rule.fr_udp500,
    google_compute_forwarding_rule.fr_udp4500,
  ]
}
