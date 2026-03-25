variable "project_name" {
  default = "task-dashboard"
}

variable "primary_region" {
  default = "us-east-1"
}

variable "secondary_region" {
  default = "us-east-2"
}

variable "vpc_cidr_primary" {
  default = "10.0.0.0/16"
}

variable "vpc_cidr_secondary" {
  default = "10.1.0.0/16"
}

variable "db_username" {
  description = "Database master username"
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "domain_name" {
  description = "The target root domain name for Route53 (e.g., example.com)"
  type        = string
  default     = "example.com"
}
