terraform {
  required_version = "0.14.7"
  required_providers {
    google = {
      version = "~> 3.30"
    }

    null = {

      version = "~> 2.1"
    }
    random = {
      version = "~> 2.2"
    }
  }
  backend "gcs" {
    bucket = "tf-backend-tq34"
    prefix = "terraform/state"
  }
}


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

resource "random_string" "db_suffix" {
  length = 4
  special = false
  upper = false
}

resource "random_string" "app_engine_backend_suffix" {
  length = 4
  special = false
  upper = false
}

module "project-factory" {
  source = "../project-factory"
  random_project_id = true
  name = local.project_name
  org_id = var.organization_id
  billing_account = var.billing_account
  credentials_path = local.credentials_file_path
  default_service_account = "deprivilege"

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


module "sql_example_postgres_private_ip" {

  source = "../terraform-google-sql" // from git submodule clone in root

  # insert the 6 required variables here
  master_user_password = var.master_user_password
  project = module.project-factory.project_id
  region = var.region
  postgres_version = "POSTGRES_13"
  db_name = "${var.db_name}-${random_string.db_suffix.id}"

  name_prefix = var.namespace
  master_user_name = var.master_user_name
  providers = {
    google-beta = google-beta
  }
}

//todo this is conflicting with the existing db connection
# resource "google_vpc_access_connector" "connector" {
#   name = "prysm-priv-vpc-connector"

#   // replace the last subnet with a 0
#   ip_cidr_range = "10.168.0.0/28"//join("",[cidrhost("${module.sql_example_postgres_private_ip.master_private_ip}/28", 0), "/28"])
#   //
#   network = module.sql_example_postgres_private_ip.private_network_name
#   region = var.region
#   project = module.project-factory.project_id
# }


resource "google_vpc_access_connector" "serverless_vpc_connector" {
  provider = "google-beta"
  name = "prysm-priv-vpc-connector"
  region = var.region
  ip_cidr_range = "72.29.167.0/28" //pick a random ip range???
  network = module.sql_example_postgres_private_ip.private_network_name
  project = module.project-factory.project_id
}
