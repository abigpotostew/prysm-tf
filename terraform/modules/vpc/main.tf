
resource "random_id" "rand_suffix" {
  byte_length = 2
}

locals {
  private_network_name = "${var.namespace}-private-network-${random_id.rand_suffix.hex}"
  private_ip_name = "${var.namespace}-private-ip-${random_id.rand_suffix.hex}"
}
# ------------------------------------------------------------------------------
# CREATE COMPUTE NETWORKS
# ------------------------------------------------------------------------------
# Simple network, auto-creates subnetworks
resource "google_compute_network" "private_network" {
  provider = google-beta
  name = local.private_network_name
  project = var.project_id
  auto_create_subnetworks=true
}

data "google_compute_subnetwork" "app_subnet" {
  name   = local.private_network_name
  region = var.region
  project= var.project_id
}

# Reserve global internal address range for the peering
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta
  name = local.private_ip_name
  purpose = "VPC_PEERING"
  address_type = "INTERNAL"
  prefix_length = 16
  network = google_compute_network.private_network.self_link
  project = var.project_id
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
//  project = var.project_id
  provider = google-beta
  network = google_compute_network.private_network.self_link
  service = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [
    google_compute_global_address.private_ip_address.name]
}

resource "google_vpc_access_connector" "serverless_vpc_connector" {
  provider = google-beta
  name = "prysm-priv-vpc-connector"
  region = var.region
  ip_cidr_range = "72.29.167.0/28"
  //pick a random ip range???
  network = google_compute_network.private_network.name
  project = var.project_id
}