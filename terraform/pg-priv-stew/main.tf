
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
  credentials_path = local.credentials_file_path
  default_service_account = "deprivilege"

//  folder_id=var.folder_id

  activate_apis = [
    "servicenetworking.googleapis.com",
    "compute.googleapis.com",
    "appengine.googleapis.com",
    "vpcaccess.googleapis.com"
  ]
  activate_api_identities = [
    {
      api = "servicenetworking.googleapis.com"
      roles = [
        "roles/servicenetworking.serviceAgent",
      ]
    },
  ]
}
resource "random_id" "rand_suffix" {
  byte_length = 2
}

locals {
  project_id = module.project-factory.project_id
  db_instance_name = format("%s-%s", var.namespace, random_id.rand_suffix.hex)
  private_network_name = "private-network-${random_id.rand_suffix.hex}"
  private_ip_name = "private-ip-${random_id.rand_suffix.hex}"
}

# ------------------------------------------------------------------------------
# CREATE COMPUTE NETWORKS
# ------------------------------------------------------------------------------
# Simple network, auto-creates subnetworks
resource "google_compute_network" "private_network" {
  provider = google-beta
  name = local.private_network_name
  project =  module.project-factory.project_id
}

# Reserve global internal address range for the peering
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  name = local.private_ip_name
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 16
  network = google_compute_network.private_network.self_link
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta
  network = google_compute_network.private_network.self_link
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_address.name]
}


# ------------------------------------------------------------------------------
# CREATE DATABASE IP PRIVATE IP
# ------------------------------------------------------------------------------
module "sql_example_postgres_private_ip" {

  //  source = "../terraform-google-sql" // todo get this from github directly
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

  private_network = google_compute_network.private_network.self_link

  # Wait for the vpc connection to complete
  dependencies = [
    google_service_networking_connection.private_vpc_connection.network]

  custom_labels = {
    test-id = "postgres-private-ip-example"
  }

  //  providers = {
  //    google-beta = google-beta
  //  }
}

resource "google_vpc_access_connector" "serverless_vpc_connector" {
  provider = google-beta
  name = "prysm-priv-vpc-connector"
  region = var.region
  ip_cidr_range = "72.29.167.0/28"
  //pick a random ip range???
  network = google_compute_network.private_network.name
  project = module.project-factory.project_id
}


module "iap_bastion" {
  source = "terraform-google-modules/bastion-host/google"

  project = module.project-factory.project_id
  zone = var.zone
  network = google_compute_network.private_network.self_link
  subnet = "10.168.0.0/20"
  //todo figure out how to get this from the region, since it's auto created
  members = var.db_bastion_members
  disk_size_gb = 5
}


module "app-engine" {
  source = "../modules/app_engine"

  billing_account = var.billing_account
  namespace = var.namespace
  org_id = var.organization_id
  project_id = module.project-factory.project_id
  vpc_access_connector_id = google_vpc_access_connector.serverless_vpc_connector.id
}