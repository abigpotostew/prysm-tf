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

variable "region" {
  default = "us-west2"
}
variable "zone" {
  default = "us-west2-a"
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
variable "organization_id" {
  type = string
}
variable "credentials_path"{
  type=string
  default="~/.config/gcloud/application_default_credentials.json"
}
variable "master_user_password"{
  type=string
}
variable "master_user_name"{
  type=string
  default="postgres"
}