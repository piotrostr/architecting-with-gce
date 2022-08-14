// cloud sql stuff
resource "google_sql_database_instance" "db_instance" {
  root_password       = var.password
  database_version    = "POSTGRES_14"
  region              = "us-central1"
  deletion_protection = false

  settings {
    tier = "db-f1-micro"
  }
}

resource "google_sql_database" "cloud_sql" {
  name     = "cloud-sql-course-database"
  instance = google_sql_database_instance.db_instance.name
}

output "cloud_sql_connection" {
  sensitive = false
  value     = google_sql_database_instance.db_instance.connection_name
}

output "cloud_sql_external_ip" {
  sensitive = false
  value     = google_sql_database_instance.db_instance.ip_address
}
