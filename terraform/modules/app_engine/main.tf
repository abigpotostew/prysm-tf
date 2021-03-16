provider "google"{
  credentials = file(var.credentials_path)
}

locals {
  appname="backend"
}

resource "google_app_engine_application" "main" {
  project        = var.project_id
  location_id    = var.location_id
  auth_domain    = var.auth_domain
  serving_status = var.serving_status
  dynamic "feature_settings" {
    for_each = var.feature_settings
    content {
      split_health_checks = lookup(feature_settings.value, "split_health_checks", true)
    }
  }
}


resource "google_storage_bucket_object" "object" {
  name = "app.zip"
  bucket = google_app_engine_application.main.code_bucket
  source = var.dist_archive
}

resource "google_app_engine_standard_app_version" "default" {
  version_id = "v0"
  service = "default"
  runtime = "nodejs10"
  project = var.location_id

  entrypoint {
    shell = "node ./index.js"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_app_engine_application.main.code_bucket}/${google_storage_bucket_object.object.name}"
    }
  }
  env_variables = var.env_var_map

  automatic_scaling {
    max_concurrent_requests = 1
    min_idle_instances = 0
    max_idle_instances = 1
    min_pending_latency = "1s"
    max_pending_latency = "5s"
  }
  noop_on_destroy = true
}


resource "google_app_engine_standard_app_version" "backend_v1" {
  depends_on = [
    google_app_engine_standard_app_version.default,
  ]
  version_id = "v1"
  service = local.appname
  runtime = "nodejs14"
  project = var.location_id

  entrypoint {
    shell = "node ./index.js"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${google_app_engine_application.main.code_bucket}/${google_storage_bucket_object.object.name}"
    }
  }

  env_variables = var.env_var_map

  automatic_scaling {
    max_concurrent_requests = 3
    min_idle_instances = 1
    max_idle_instances = 3
    min_pending_latency = "1s"
    max_pending_latency = "5s"
    standard_scheduler_settings {
      target_cpu_utilization = 0.5
      target_throughput_utilization = 0.5
      min_instances = 2
      max_instances = 10
    }
  }

  delete_service_on_destroy = true
  //  noop_on_destroy = true

  // opens the private db to app engine
  vpc_access_connector{
    name= var.vpc_access_connector_id
    //"projects/${module.project-factory.project_id}/locations/${var.region}/connectors/${module.sql_example_postgres_private_ip.connector_name}"
  }
  //todo pass in the private ip of the db
}
