locals {
  appname="backend"
}

module "app-engine" {
  source = "../../modules/app_engine"
  project_id = module.project-factory.project_id
  location_id = var.location_id

}

resource "google_storage_bucket_object" "object" {
  name = "hello-world.zip"
  bucket = module.app-engine.code_bucket
  source = "../../hello-world.zip"
}

resource "google_app_engine_standard_app_version" "default" {
  version_id = "v0"
  service = "default"
  runtime = "nodejs10"
  project = module.project-factory.project_id

  entrypoint {
    shell = "node ./app.js"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${module.app-engine.code_bucket}/${google_storage_bucket_object.object.name}"
    }
  }

  env_variables = {
    port = "8080"
  }
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
  project = module.project-factory.project_id

  entrypoint {
    shell = "node ./app.js"
  }

  deployment {
    zip {
      source_url = "https://storage.googleapis.com/${module.app-engine.code_bucket}/${google_storage_bucket_object.object.name}"
    }
  }

  env_variables = {
    port = "8080"
  }

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
}
