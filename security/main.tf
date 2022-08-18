// having defined the custom role
resource "google_project_iam_custom_role" "iam_admin" {
  role_id = "iamAdmin"
  title = "IAM Admininstrator"
  permissions = [
    "iam.roles.get",
    "iam.roles.list",
    "iam.roles.create",
    "iam.roles.delete",
    "iam.roles.update",
    "iam.roles.undelete",
  ]
}

// create members like that
resource "google_project_iam_member" "admin" {
  // role can be specified directly here
  role = google_project_iam_custom_role.iam_admin.name
  member = "user:piotrostr@google.com"
  project = var.project
}

// create a service account
resource "google_service_account" "service_account" {
  account_id = "admin-service-account"
  display_name = "Admin Service Account"
}

// create a binding for the service account
resource "google_project_iam_binding" "iam_admin_permissions_binding" {
  role = google_project_iam_custom_role.iam_admin.name
  project = var.project
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

// then the service account can be used with instances and other resources
// e.g.
// resource "google_compute_instance" "example" {
//   name = "example-instance"
//   ...
//   service_account {
//     email = google_service_account.service_account.email
//   }
//   ...
// }
