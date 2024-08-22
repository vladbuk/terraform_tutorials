variable "region" {
  default = "us-east1"
}

variable "zone" {
  default = "us-east1-b"
}

variable "public_key" {
  description = "The public SSH key to add to the instance metadata"
  type        = string
  sensitive   = true
}