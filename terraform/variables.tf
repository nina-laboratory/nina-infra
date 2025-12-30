variable "subscription_id" {
  description = "The Azure subscription ID"
  type        = string
}

variable "location" {
  description = "The Azure region to deploy resources"
  type        = string
  default     = "Germany West Central"
}

variable "domain_name" {
  description = "The root domain name for the applications"
  type        = string
  default     = "ninalabs.de"
}

variable "apps" {
  description = "List of application names to deploy"
  type        = set(string)
  default     = ["fit", "quick", "journal"]
}

variable "default_image" {
  description = "The default container image to use if not specified in app_images"
  type        = string
  default     = "mcr.microsoft.com/k8se/quickstart:latest"
}

variable "app_images" {
  description = "Map of application names to specific container images. Key must match an entry in 'apps'."
  type        = map(string)
  default     = {}
}
