# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Lookup the correct AMI based on the region specified
data "aws_ami" "amazon_windows_2012R2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["Windows_Server-2012-R2_RTM-English-64Bit-Base-*"]
  }
}

# Lookup ebs volume based on Name tag
data "aws_ebs_volume" "ebs_volume" {
  most_recent = true

  filter {
    name   = "snapshot-id"
    values = [""]
  }

  filter {
    name   = "tag:Name"
    values = ["${var.ebs_name}"]
  }
}

# Attach ebs volume to instance
resource "aws_volume_attachment" "ebs_att" {
  device_name  = "xvdj"
  volume_id    = "${data.aws_ebs_volume.ebs_volume.volume_id}"
  instance_id  = "${aws_instance.ebs_example.id}"
  skip_destroy = true

  lifecycle {
    ignore_changes = ["tags"]
  }
}

resource "aws_instance" "ebs_example" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type     = "winrm"
    user     = "Administrator"
    password = "${var.admin_password}"
  }

  instance_type = "t2.micro"
  ami           = "${data.aws_ami.amazon_windows_2012R2.image_id}"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs
  #
  key_name = "${var.key_name}"

  user_data = <<EOF
<powershell>
# Mount ebs volume disk 1 with read-write access (should mount as D: drive)
set-disk 1 -isOffline $false
set-disk 1 -isReadOnly $false

# Set Administrator password
$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "${var.admin_password}")
</powershell>
EOF
}
