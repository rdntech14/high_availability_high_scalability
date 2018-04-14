output "vpc_id" {
  value = "${aws_vpc.vpc_trf.id}"
}

output "subnets_ids" {
  value = "${aws_subnet.subnets.*.id}"
}

output "subnets_ids_1" {
  value = "${aws_subnet.subnets.0.id}"
}

output "subnets_cidr_blocks" {
  value = "${aws_subnet.subnets.*.cidr_block}"
}

# output "sg_elb_id" {
#   value = "${aws_security_group.sg_elb.id}"
# }

output "sg_web_id" {
  value = "${aws_security_group.sg_web.id}"
}

output "sg_db_id" {
  value = "${aws_security_group.sg_db.id}"
}

output "ec2_db_private_ip" {
  value = "${aws_instance.ec2_db.private_ip}"
}
