# Create GKE
resource "google_compute_network" "default" {
  name                    = "network"
  project                 = var.project_id
  auto_create_subnetworks  = false
  enable_ula_internal_ipv6 = true
}

resource "google_compute_subnetwork" "default" {
  name = "subnetwork"

  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"

  stack_type       = "IPV4_ONLY"
  # ipv6_access_type = "INTERNAL"     

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  network = google_compute_network.default.id
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "192.168.0.0/24"
  }

  secondary_ip_range {
    range_name    = "pod-ranges"
    ip_cidr_range = "192.168.1.0/24"
  }
}

resource "google_container_cluster" "default" {
  name = "autopilot-cluster"

  location                 = "us-central1"
  enable_autopilot         = true
  enable_l4_ilb_subsetting = true

  network    = google_compute_network.default.id
  subnetwork = google_compute_subnetwork.default.id
  
  private_cluster_config {
    enable_private_nodes    = true
    # enable_private_endpoint = true
  }
  
  ip_allocation_policy {
    stack_type                    = "IPV4"
    services_secondary_range_name = google_compute_subnetwork.default.secondary_ip_range[0].range_name
    cluster_secondary_range_name  = google_compute_subnetwork.default.secondary_ip_range[1].range_name
  }

  # Set `deletion_protection` to `true` will ensure that one cannot
  # accidentally delete this instance by use of Terraform.
  deletion_protection = false
}
# [END gke_quickstart_autopilot_cluster]
