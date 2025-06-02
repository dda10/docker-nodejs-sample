# [Create Workload Identity Federation]
resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-action-pool"
  display_name = "Github Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "my-repo"
  display_name                       = "My GitHub repo Provider"
  description                        = "GitHub Actions identity pool provider for automated test"
  disabled                           = false
  attribute_condition = <<EOT
    assertion.repository_owner == "dda10" &&
    attribute.repository == "dda10/docker-nodejs-sample" &&
    assertion.ref == "refs/heads/main" &&
    assertion.ref_type == "branch"
  EOT
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.aud"        = "assertion.aud"
    "attribute.repository" = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# [END create_workload_identity_federation]

# [Create IAM Service Account]
resource "google_service_account" "github_service_account" {
  account_id = "github-actions"
  display_name = "GitHub Actions Service Account"
}

# [END create_iam_service_account]

# [Create IAM Role Binding]
resource "google_service_account_iam_binding" "github_workload_identity_binding" {
  service_account_id = google_service_account.github_service_account.name
  role              = "roles/iam.workloadIdentityUser"
  members           = [
    "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/dda10/docker-nodejs-sample"
  ]
}

# Grant IAM roles to the service account
resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset([
    "roles/container.developer",
    "roles/artifactregistry.writer",
    "roles/iam.serviceAccountTokenCreator",
    # "roles/iam.workloadIdentityUser",
    # Add more roles here as needed
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.github_service_account.email}"
}

# [END create_iam_role_binding]
