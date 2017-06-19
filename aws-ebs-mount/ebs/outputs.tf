output "availability_zone" {
  value = "${aws_ebs_volume.ebs.availability_zone}"
}

output "id" {
  value = "${aws_ebs_volume.ebs.id}"
}

output "size" {
  value = "${aws_ebs_volume.ebs.size}"
}
