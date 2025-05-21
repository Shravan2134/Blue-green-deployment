variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "region" {
  description = "Deployment region"
  type        = string
  default     = "us-central1"
}

variable "instance_template_name" {
  description = "Instance template name"
  type        = string
}

variable "blue_instance_group_name" {
  description = "Blue environment instance group"
  type        = string
}

variable "green_instance_group_name" {
  description = "Green environment instance group"
  type        = string
}

variable "load_balancer_name" {
  description = "Global Load Balancer name"
  type        = string
}

