variable "project_id" {
  description = "project id"
  sensitive   = true
}

variable "region" {
  description = "region"
  default = "us-central1"
}

variable "TFC_GCP_PROVIDER_AUTH" {
  description = "TFC_GCP_PROVIDER_AUTH"
}

variable "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL" {
  description = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
}

variable "TFC_GCP_WORKLOAD_PROVIDER_NAME" {
  description = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
}