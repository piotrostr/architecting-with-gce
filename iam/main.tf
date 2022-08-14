# the roles can be applied to a single member in a fashion as below
# resource "google_project_iam_member" "member_tom" {
#   member = "user:tom@example.com"
#   role = "roles/storage.objectViewer"
#   project = var.project
# }

resource "google_service_account" "sa" {
  account_id   = "my-service-account"
  display_name = "A service account that only Tom can use"
}

resource "google_service_account_iam_binding" "admin-account-iam" {
  service_account_id = google_service_account.sa.id
  role               = "roles/iam.serviceAccountUser"

  members = [
    "user:piotrostr@google.com",
  ]
}
