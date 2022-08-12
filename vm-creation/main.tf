module "vpc" {
  source                  = "terraform-google-modules/network/google//modules/vpc"
  auto_create_subnetworks = true
  project_id              = var.project
  network_name            = "course-vpc"
}

module "instance" {
  source  = "../modules/instance"
  name    = "course-instance"
  network = module.vpc.network_id
  region  = var.region
}
