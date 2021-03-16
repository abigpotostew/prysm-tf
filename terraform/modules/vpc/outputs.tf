output private_network {
  value = google_compute_network.private_network
}
output private_ip_address {
  value = google_compute_global_address.private_ip_address
}
output app_subnet {
  value = data.google_compute_subnetwork.app_subnet.self_link
}
output private_vpc_connection {
  value = google_service_networking_connection.private_vpc_connection
}
output serverless_vpc_connector_id {
  value = google_vpc_access_connector.serverless_vpc_connector.id
}
