# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Create ebs volume with Name tag set
resource "aws_ebs_volume" "ebs" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.ebs_size}"
  type              = "gp2"

  tags {
    Name = "${var.ebs_name}"
  }

  lifecycle {
    ignore_changes = ["tags"]
  }
}
