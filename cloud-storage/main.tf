resource "google_storage_bucket" "course_bucket" {
  name     = "${var.project}-course-bucket"
  location = "EU"
}

resource "google_storage_bucket_access_control" "fine_grained" {
  bucket = google_storage_bucket.course_bucket.id
  entity = "allAuthenticatedUsers"
  role   = "READER"
}

resource "google_service_account" "bucket_editor" {
  account_id = "terraform-bucket-editor"
  display_name = "Terraform Bucket Editor"
}

resource "google_service_account_key" "name" {
  service_account_id = google_service_account.bucket_editor.id
}

resource "google_service_account_iam_binding" "bucket_admin" {
  service_account_id = google_service_account.bucket_editor.id
  members = [
    "user:piotrostr@google.com",
  ]
  role = "roles/iam.serviceAccountUser"
}

output "credentials" {
  sensitive = true
  value = google_service_account_key.name.private_key
}
