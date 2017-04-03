provider "aws" {
  region = "${var.aws_region}"
}

data "template_file" "asg_user_data" {
  template = "asg_user_data.tpl"

  vars {
    name        = "example"
    environment = "default"
    run_list    = "nginx"
  }
}

# Lookup the correct AMI based on the region specified
data "aws_ami" "amazon_windows_2012R2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
}

resource "aws_launch_configuration" "example" {
  name          = "example"
  image_id      = "${data.aws_ami.amazon_windows_2012R2.image_id}"
  instance_type = "m1.small"

  key_name             = "panext"
  iam_instance_profile = "chef-provisioning-role"

  root_block_device {
    volume_size = "50"
  }

  user_data = "${data.template_file.asg_user_data.rendered}"
}

resource "aws_autoscaling_group" "example" {
  name                      = "example"
  availability_zones        = ["us-east-1a", "us-east-1c"]
  vpc_zone_identifier       = ["subnet-a1b2c3d4e5", "subnet-1a2b3c4d5e"]
  max_size                  = 2
  min_size                  = 2
  desired_capability        = 2
  health_check_grace_period = 300
  health_check_type         = "EC2"
  default_cooldown          = 300
  force_delete              = true
  launch_configuration      = "${aws_launch_configuration.example.name}"

  tag {
    key                 = "Name"
    value               = "example"
    propagate_at_launch = true
  }
}
