resource "google_compute_address" "vpn_address_1" {
  name = "vpn-address-1"
}

resource "google_compute_address" "vpn_address_2" {
  name = "vpn-address-2"
}

resource "google_compute_vpn_gateway" "vpn_1" {
  name    = "vpn-1"
  network = google_compute_network.network_1.name
}

resource "google_compute_forwarding_rule" "fr_esp_1" {
  name        = "fr-esp-1"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_address_1.address
  // the target has to be using `id`, not `name` or `self_link`
  target = google_compute_vpn_gateway.vpn_1.id
}

resource "google_compute_forwarding_rule" "fr_udp500_1" {
  name        = "fr-udp500-1"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_address_1.address
  target      = google_compute_vpn_gateway.vpn_1.id
}

resource "google_compute_forwarding_rule" "fr_udp4500_1" {
  name        = "fr-udp4500-1"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_address_1.address
  target      = google_compute_vpn_gateway.vpn_1.id
}

resource "google_compute_vpn_tunnel" "tunnel_1_to_2" {
  name                    = "tunnel-1-to-2"
  shared_secret           = "gcprocks"
  target_vpn_gateway      = google_compute_vpn_gateway.vpn_1.id
  peer_ip                 = google_compute_address.vpn_address_2.address
  remote_traffic_selector = ["10.128.0.0/20"] // network_2 (eu)
  local_traffic_selector  = ["10.132.0.0/20"] // network_1 (us)

  depends_on = [
    // the rules below are required to be in deps and to be created
    google_compute_forwarding_rule.fr_esp_1,
    google_compute_forwarding_rule.fr_udp500_1,
    google_compute_forwarding_rule.fr_udp4500_1,
  ]
}

resource "google_compute_route" "route_1" {
  name                = "route-1"
  network             = google_compute_network.network_1.name
  dest_range          = "0.0.0.0/0"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel_1_to_2.id
}

resource "google_compute_vpn_gateway" "vpn_2" {
  name    = "vpn-2"
  network = google_compute_network.network_2.name
}

resource "google_compute_forwarding_rule" "fr_esp_2" {
  name        = "fr-esp-2"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vpn_address_2.address
  // the target has to be using `id`, not `name` or `self_link`
  target = google_compute_vpn_gateway.vpn_2.id
}

resource "google_compute_forwarding_rule" "fr_udp500_2" {
  name        = "fr-udp500-2"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vpn_address_2.address
  target      = google_compute_vpn_gateway.vpn_2.id
}

resource "google_compute_forwarding_rule" "fr_udp4500_2" {
  name        = "fr-udp4500-2"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vpn_address_2.address
  target      = google_compute_vpn_gateway.vpn_2.id
}

resource "google_compute_vpn_tunnel" "tunnel_2_to_1" {
  name                    = "tunnel-2-to-1"
  shared_secret           = "gcprocks"
  target_vpn_gateway      = google_compute_vpn_gateway.vpn_2.id
  peer_ip                 = google_compute_address.vpn_address_1.address
  remote_traffic_selector = ["10.132.0.0/20"] // network_1 (us)
  local_traffic_selector  = ["10.128.0.0/20"] // network_2 (eu)

  depends_on = [
    // the rules below are required to be in deps and to be created
    google_compute_forwarding_rule.fr_esp_2,
    google_compute_forwarding_rule.fr_udp500_2,
    google_compute_forwarding_rule.fr_udp4500_2,
  ]
}

resource "google_compute_route" "route_2" {
  name                = "route-2"
  network             = google_compute_network.network_2.name
  dest_range          = "0.0.0.0/0"
  priority            = 1000
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.tunnel_2_to_1.id
}
