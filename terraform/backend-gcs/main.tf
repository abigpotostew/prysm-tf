terraform {
  required_version="0.14.7"
  required_providers {
    google={version = "~> 3.30"}
    null={version = "~> 2.1"}
    random={version = "~> 2.2"}
  }
}


locals {
  credentials_file_path = var.credentials_path
  project_name = "prysm-shared-tf"
}

/******************************************
  Provider configuration
 *****************************************/
provider "google" {
  credentials = file(local.credentials_file_path)
  
  region = var.location_id
  zone = var.zone
}

provider "google-beta" {
  credentials = file(local.credentials_file_path)
  
  region = var.location_id
  zone = var.zone
}

provider "null" {
}

provider "random" {
}

resource "random_string" "tf-backend_suffix" {
  length  = 4
  special = false
  upper   = false
}


module "project-factory" {
  source = "..\/..\/.."
  random_project_id = false
  name = local.project_name
  org_id = var.organization_id
  billing_account = var.billing_account
  credentials_path = local.credentials_file_path
  default_service_account = "deprivilege"

#   activate_apis=[
#     "servicenetworking.googleapis.com",
#     "compute.googleapis.com",
#     "appengine.googleapis.com"
#   ]
#   activate_api_identities = [
#     {
#       api = "servicenetworking.googleapis.com"
#       roles = [
#         "roles/servicenetworking.serviceAgent",
#       ]
#     },
#     ]
}

resource "google_storage_bucket" "tf-backend" {
    name          = "tf-backend-${random_string.tf-backend_suffix.id}"
  
    force_destroy = true

    uniform_bucket_level_access = true
    location      = "US"    
    project= module.project-factory.project_id

#     providers = {
#     google-beta = google-beta
#   }
}