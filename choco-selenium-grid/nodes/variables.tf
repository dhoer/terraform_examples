variable "admin_password" {
  description = "Windows Administrator password to login as."
}

variable "hub_url" {
  description = "The url to selenium hub, e.g., http://selenium.example.com:4444"
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}
