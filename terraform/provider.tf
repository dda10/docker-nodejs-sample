terraform {
  cloud {
    organization = "anhdd01"
    
    workspaces {
      project = "docker-nodejs-sample"
      name = "docker-nodejs-sample"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}