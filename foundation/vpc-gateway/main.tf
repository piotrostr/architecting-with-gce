resource "google_compute_network" "course_network" {
  name                    = "course-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "course_subnetwork" {
  name                     = "course-subnetwork"
  ip_cidr_range            = "10.130.0.0/20"
  region                   = var.region
  network                  = google_compute_network.course_network.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "web_ssh_firewall" {
  name        = "web-ssh"
  network     = google_compute_network.course_network.id
  source_tags = ["web"]

  allow {
    protocol = "icmp"
  }

  allow {
    ports    = ["80", "22", "443"]
    protocol = "tcp"
  }

  # adding this access source ranges enables connecting to the VM
  # it also makes it so that EGRESS is blocked
  source_ranges = ["35.235.240.0/20"]
}

resource "google_compute_router" "course_router" {
  name    = "course-router"
  network = google_compute_network.course_network.id
}

resource "google_compute_router_nat" "course_nat" {
  name                               = "course-nat"
  router                             = google_compute_router.course_router.id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  subnetwork {
    name                    = google_compute_subnetwork.course_subnetwork.name
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = true
    filter = "ALL"
  }

}

module "course_instance" {
  source     = "./instance"
  count      = 1
  name       = format("course-instance-%d", count.index)
  network    = google_compute_network.course_network.id
  subnetwork = google_compute_subnetwork.course_subnetwork.id
  region     = var.region
}
