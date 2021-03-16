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
variable dist_archive {
  type = string
  description = "the distributed archive application"
}
variable "namespace" {
  description = "project namespace"
  type = string
}

variable "org_id" {
  description = "The organization ID."
  type        = string
}

variable "folder_id" {
  description = "The ID of a folder to host this project."
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "location_id" {
  description = "The location to serve the app from."
  default     = "us-west2"
}

variable "network_name" {
  description = "private db network"
  type=string
  default="apps-private-network"
}

variable "db_name" {
  description="database name"
  type=string
  default = "prysm-main"
}
variable "authorized_networks" {
  type = list(map(string))
  default=[]
}

variable "project_id" {
  description="project id"
  type=string
}

variable "vpc_access_connector_id" {
  description="google_vpc_access_connector.serverless_vpc_connector.id"
  type=string
}

//app engine optional
variable "auth_domain" {
  description = "The domain to authenticate users with when using App Engine's User API."
  default     = ""
}

variable "serving_status" {
  description = "The serving status of the app."
  default     = "SERVING"
}

variable "feature_settings" {
  description = "A list of maps of optional settings to configure specific App Engine features."
  type        = list(object({ split_health_checks = bool }))
  default     = [{ split_health_checks = true }]
}

variable "env_var_map" {
  type =map(string)
  default = {}
}

variable "credentials_path" {
  type=string
}