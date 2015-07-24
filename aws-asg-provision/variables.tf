variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "us-east-1"
}

# Windows Server 2012 R2 Base
variable "aws_amis" {
  default = {
    us-east-1 = "ami-5b9e6b30"
  }
}
