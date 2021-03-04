/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

provider "google" {
  version = "~> 3.30"
}

provider "google-beta" {
  version = "~> 3.30"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

locals {
  project_id = "prysm-${var.namespace}"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
}

module "app-engine-project" {
  source = "..\/..\/.."
  name = local.project_id
  random_project_id = false
  org_id = var.org_id
  folder_id = var.folder_id
  billing_account = var.billing_account
  //  location_id =  "us-west2"
  activate_apis = [
    "appengine.googleapis.com",

  ]
}

// enable service networking for private db
resource "google_project_service" "servicenetworking" {
  project = local.project_id
  service = "servicenetworking.googleapis.com"
}

module "app-engine" {
  source = "..\/..\/..\/modules\/app_engine"
  project_id = local.project_id
  location_id = "us-west2"
}


resource "google_app_engine_standard_app_version" "default" {
  version_id = "v0"
  service = "default"
  runtime = "nodejs10"
  project = local.project_id

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

resource "google_app_engine_standard_app_version" "myapp_v1" {
  depends_on = [
    google_app_engine_standard_app_version.default,
  ]
  version_id = "v1"
  service = "myapp"
  runtime = "nodejs14"
  project = local.project_id

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


resource "google_app_engine_standard_app_version" "myapp_v2" {
  depends_on = [
    google_app_engine_standard_app_version.default,
  ]
  version_id = "v2"
  service = "myapp"
  // myapp
  runtime = "nodejs14"
  project = local.project_id

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
    min_idle_instances = 0
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

resource "google_storage_bucket_object" "object" {
  name = "hello-world.zip"
  bucket = module.app-engine.code_bucket
  //google_storage_bucket.bucket.name
  source = "../../hello-world.zip"
}

resource "google_app_engine_service_split_traffic" "myapp" {
  service = google_app_engine_standard_app_version.myapp_v1.service

  project = local.project_id
  migrate_traffic = false
  split {
    shard_by = "IP"
    allocations = {
      (google_app_engine_standard_app_version.myapp_v1.version_id) = 0.75
      (google_app_engine_standard_app_version.myapp_v2.version_id) = 0.25
    }
  }
}
