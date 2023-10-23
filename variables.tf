variable "project_id" {
  type = string
  description = "The project ID where all resources are kept"
  default = "tf-gcp-project"
}

variable "region" {
  type = string
  description = "Region in GCP for the resources"
  default = "us-central1"
}

variable "zone" {
  type = string
  description = "Zone in GCP for the resources"
  default = "us-central1-a"
}
