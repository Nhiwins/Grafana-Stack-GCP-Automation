provider "google" {
  credentials = "file("/home/nnguyen/.config/gcloud/application_default_credentials.json")"
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  }
