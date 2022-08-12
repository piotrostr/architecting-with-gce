resource "google_compute_instance" "course_instance" {
  name           = var.name
  machine_type   = "n1-standard-1"
  zone           = "${var.region}-c"
  can_ip_forward = true

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork
  }

  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20220719"
    }
  }
}
