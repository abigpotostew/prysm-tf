
module "postgresql-db" {
  source               = "..\/..\/..\/modules\/postgresql"
  name                 = var.db_name
  random_instance_name = true
  database_version     = "POSTGRES_9_6"
  project_id           = module.app-engine-project.project_id
  zone                 = "us-central1-c"
  region               = "us-central1"
  tier                 = "db-f1-micro"

  deletion_protection = false

  ip_configuration = {
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = true
    authorized_networks = var.authorized_networks
  }
}
