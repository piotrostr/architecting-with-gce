variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "password" {
  type = string
  default = "password"
  description = "the root password for logging in as the database admin"
}
