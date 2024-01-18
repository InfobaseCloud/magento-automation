#########################
## General Vars
##########################

variable "region" {
  type        = string
  description = "Region in which we deploy the resources in."
  default     = "us-east-1"
}

variable "name" {
  type        = string
  description = "Name for the resources"
}

variable "managed_by" {
  type        = string
  description = "Managed By automation tool name"
  default     = "Terraform"
}


variable "env" {
  type        = string
  description = "Environment Stage"
}


variable "owner" {
  type        = string
  description = "Owner of the infrastructure"
  default     = "Emmanuel Torrado"
}

variable "tags" {
  type        = any
  description = "Resource Tags"
  default     = {}
}

variable "endpoint" {
  type        = string
  description = "Endpoint to send notifications to."
  default     = "test-notifications-aaaal2efgn7ci34osq4bnh3hem@infobasedigital.slack.com"
}

variable "instance_ids" {
  description = "List of EC2 instance IDs"
  type        = list(string)
  default     = []
}