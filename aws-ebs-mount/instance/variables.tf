variable "ebs_name" {
  description = "Tag Name of ebs volume to mount."
  default     = "terraform_ebs_example"
}

variable "admin_password" {
  description = "Windows Administrator password to login as."
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}
