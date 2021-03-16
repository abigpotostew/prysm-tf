//terraform {
//  required_version = "0.14.7"
//  required_providers {
//    google = {
//      version = "~> 3.30"
//    }
//    null = {
//      version = "~> 2.1"
//    }
//    random = {
//      version = "~> 2.2"
//    }
//  }
//}
//
//
//locals {
//  credentials_file_path = var.credentials_path
//  project_name = "prysm-tf-state"
//  bucket_name = "prysm-tf-state"
//}
//
///******************************************
//  Provider configuration
// *****************************************/
//provider "google" {
//  credentials = file(local.credentials_file_path)
//
//  region = var.location_id
//  zone = var.zone
//}
//
//provider "google-beta" {
//  credentials = file(local.credentials_file_path)
//
//  region = var.location_id
//  zone = var.zone
//}
//
//provider "null" {
//}
//
//provider "random" {
//}
//
//resource "random_string" "tf-backend_suffix" {
//  length = 4
//  special = false
//  upper = false
//}
//
//
//module "project-factory" {
//  source = "terraform-google-modules/project-factory/google"
//  version = "10.1.1"
//
//  random_project_id = true
//  name = local.project_name
//  org_id = var.organization_id
//  billing_account = var.billing_account
//  credentials_path = local.credentials_file_path
//  default_service_account = "deprivilege"
//
////  activate_apis = [
////    "servicenetworking.googleapis.com",
////    "compute.googleapis.com",
////    "appengine.googleapis.com",
////    "vpcaccess.googleapis.com"
////  ]
////  activate_api_identities = [
////    {
////      api = "servicenetworking.googleapis.com"
////      roles = [
////        "roles/servicenetworking.serviceAgent",
////      ]
////    },
////  ]
//
//}
//
//resource "google_storage_bucket" "tf-backend" {
//  name = "${local.bucket_name}-${random_string.tf-backend_suffix.id}"
//
//  force_destroy = false
//  uniform_bucket_level_access = true
//  location = "US"
//  project = module.project-factory.project_id
//}

terraform {
  required_version = "0.14.7"
  required_providers {
    google = {
      version = "~> 3.50"
    }
  }
}

module "bootstrap" {
  source = "terraform-google-modules/bootstrap/google"
  version = "2.2.0"
  # insert the 4 required variables here
  org_id = var.organization_id
  billing_account = var.billing_account
  group_org_admins = var.group_org_admins
  group_billing_admins = var.group_billing_admins
  default_region = var.location_id
  project_prefix = "prysm"
}