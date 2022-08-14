resource "google_storage_bucket" "course_bucket" {
  name     = "${var.project}-course-bucket"
  location = "EU"
}

resource "google_storage_bucket_access_control" "fine_grained" {
  bucket = google_storage_bucket.course_bucket.id
  entity = "allAuthenticatedUsers"
  role   = "READER"
}
