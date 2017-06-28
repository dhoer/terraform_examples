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

  # EC2Config service does not take actions on disks that have already been
  # initialized. It only provisions newer 'raw' disks, formats them and assigns
  # them with driver letters. So Powershell's Get-Disk function is used to
  # bring ebs volume online with read-write access after it has already been
  # initialized. It should assign it with the letter D: by default.
  #
  # See the following for more info about managing storage with windows:
  # https://blogs.msdn.microsoft.com/san/2012/07/03/managing-storage-with-windows-powershell-on-windows-server-2012/
  user_data = <<EOF
<powershell>
# Bring ebs volume online with read-write access
Get-Disk | Where-Object IsOffline –Eq $True | Set-Disk –IsOffline $False
Get-Disk | Where-Object isReadOnly -Eq $True | Set-Disk -IsReadOnly $False

# Set Administrator password
$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "${var.admin_password}")
</powershell>
EOF
}
