locals {
  credentials_file_path = var.credentials_path
  project_name = "prysm-${var.namespace}"
}

/******************************************
  Provider configuration
 *****************************************/
provider "google" {
  credentials = file(local.credentials_file_path)
  region = var.region
  zone = var.zone
}
provider "google-beta" {
  credentials = file(local.credentials_file_path)
  region = var.region
  zone = var.zone
  //  project = module.project-factory.project_id
}
provider "null" {
}
provider "random" {
}

module "project-factory" {
  source = "terraform-google-modules/project-factory/google"
  version = "10.1.1"

  random_project_id = true
  name = local.project_name
  org_id = var.organization_id
  billing_account = var.billing_account
//  credentials_path = local.credentials_file_path
  default_service_account = "keep"

  //  folder_id=var.folder_id

  activate_apis = [
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "appengine.googleapis.com",
    "vpcaccess.googleapis.com",
    "iap.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ]
  activate_api_identities = [
    {
      api = "servicenetworking.googleapis.com"
      roles = [
        "roles/servicenetworking.serviceAgent",
      ]
    },
//    {
//      api = "appengine.googleapis.com"
//      roles = [
//        "roles/appengine.serviceAgent",
//      ]
//    },
  ]
}

resource "random_id" "rand_suffix" {
  byte_length = 2
}

locals {
  project_id = module.project-factory.project_id
  db_instance_name = format("%s-%s", var.namespace, random_id.rand_suffix.hex)
  //  private_network_name = "private-network-${random_id.rand_suffix.hex}"
  //  private_ip_name = "private-ip-${random_id.rand_suffix.hex}"
}

module "vpc" {
  source = "../modules/vpc"

  namespace = var.namespace
  project_id = module.project-factory.project_id
  //  vpc_access_connector_id = google_vpc_access_connector.serverless_vpc_connector.id
}


# ------------------------------------------------------------------------------
# CREATE DATABASE IP PRIVATE IP
# ------------------------------------------------------------------------------
module "sql_example_postgres_private_ip" {

  source = "github.com/gruntwork-io/terraform-google-sql.git//modules/cloud-sql?ref=v0.4.0"

  # insert the 6 required variables here
  project = module.project-factory.project_id
  region = var.region
  name = local.db_instance_name
  db_name = var.db_name

  engine = "POSTGRES_13"
  machine_type = var.db_machine_type
  deletion_protection = false

  master_user_name = var.master_user_name
  master_user_password = var.master_user_password


  private_network = module.vpc.private_network.self_link
  // google_compute_network.private_network.self_link

  # Wait for the vpc connection to complete
  dependencies = [
    module.vpc.private_vpc_connection.network]

  custom_labels = {
    test-id = "postgres-private-ip-example"
  }

  //maybe not needed here
  //  providers = {
  //    google-beta = google-beta
  //  }
}


module "iap_bastion" {
  source = "terraform-google-modules/bastion-host/google"

  project = module.project-factory.project_id
  zone = var.zone
  network = module.vpc.private_network.self_link
  subnet = module.vpc.app_subnet
  //data.google_compute_subnetwork.app_subnet.self_link
  //  subnet = "10.168.0.0/20"
  //todo figure out how to get this from the region, since it's auto created
  members = var.db_bastion_members
  disk_size_gb = 23
}


module "app-engine" {
  source = "../modules/app_engine"

  dist_archive = abspath("../../app.zip")

  billing_account = var.billing_account
  namespace = var.namespace
  org_id = var.organization_id
  project_id = module.project-factory.project_id
  vpc_access_connector_id = module.vpc.serverless_vpc_connector_id

  env_var_map = merge(var.env_var_map,
  { POSTGRESQL_HOST = module.sql_example_postgres_private_ip.master_private_ip_address })

  credentials_path = var.credentials_path
//  providers {
//
//    credentials = file(local.credentials_file_path)
//    region = var.region
//    zone = var.zone
//  }
}