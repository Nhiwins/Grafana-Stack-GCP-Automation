provider "google" {
  credentials = "file("/home/nnguyen/.config/gcloud/application_default_credentials.json")"
  project     = "tf-gcp-project"
  region      = "us-central1"
  zone        = "us-central1-a"
  }
