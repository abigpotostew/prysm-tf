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

variable "location_id" {
  description = "The location to serve the app from."
  default     = "us-west2"
}

variable "namespace" {
  description = "network namespace prefix"
  type=string
}

//variable "vpc_access_connector_id" {
//  description="google_vpc_access_connector.serverless_vpc_connector.id"
//  type=string
//}
variable "project_id" {
  type=string
}
variable "region" {

  default = "us-west2"
}
variable "zone" {
  default = "us-west2-a"
}
variable "credentials_path"{
  type=string
  default="~/.config/gcloud/application_default_credentials.json"
}
