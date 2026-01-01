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

variable "image_tags" {
  description = "Map of application names to specific container image tags. Key must match an entry in 'apps'."
  type        = map(string)
  default     = {}
}
