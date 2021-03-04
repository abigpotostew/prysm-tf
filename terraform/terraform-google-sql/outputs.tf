# ------------------------------------------------------------------------------
# MASTER OUTPUTS
# ------------------------------------------------------------------------------

output "master_instance_name" {
  description = "The name of the database instance"
  value       = "${module.postgres.master_instance_name}"
}

output "master_ip_addresses" {
  description = "All IP addresses of the instance as list of maps, see https://www.terraform.io/docs/providers/google/r/sql_database_instance.html#ip_address-0-ip_address"
  value       = "${module.postgres.master_ip_addresses}"
}

output "master_private_ip" {
  description = "The private IPv4 address of the master instance"
  value       = "${module.postgres.master_private_ip_address}"
}

output "master_instance" {
  description = "Self link to the master instance"
  value       = "${module.postgres.master_instance}"
}

output "master_proxy_connection" {
  description = "Instance path for connecting with Cloud SQL Proxy. Read more at https://cloud.google.com/sql/docs/mysql/sql-proxy"
  value       = "${module.postgres.master_proxy_connection}"
}

# ------------------------------------------------------------------------------
# DB OUTPUTS
# ------------------------------------------------------------------------------

output "db_name" {
  description = "Name of the default database"
  value       = "${module.postgres.db_name}"
}

output "db" {
  description = "Self link to the default database"
  value       = "${module.postgres.db}"
}

output "private_network_name" {
  value = google_compute_network.private_network.name

}

output "connector_name"{
  description="fully qualified, ie projects/prysm-stew-bracken-3c08/global/networks/private-network-98e8"
  value=google_compute_network.private_network.name
}
