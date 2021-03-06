
variable "billing_account" {
  description = "The ID of the billing account to associate this project with"
  type        = string
}

variable "location_id" {
  description = "The location to serve the app from."
  default     = "us-west2"
}

variable "zone" {
  description = "The location to serve the app from."
  default     = "us-west2-a"
}
variable "organization_id" {
  type = string
}
variable "group_org_admins"{
  type=string
}
variable "group_billing_admins"{
  type=string
}

variable "credentials_path" {
  type=string
  default="~/.config/gcloud/application_default_credentials.json"
}