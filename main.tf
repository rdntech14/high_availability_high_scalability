provider "aws" {
  region = "${var.AWS_REGION}"
}

# Generate Random Number
resource "random_integer" "number" {
  min = 11111
  max = 99999
}

# Create VPC
resource "aws_vpc" "vpc_trf" {
  cidr_block = "${var.vpc_cidr}"

  #### this 2 true values are for use the internal vpc dns resolution
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "vpc_trf_${random_integer.number.result}"
  }
}

# Create Internet Gateway ( Otherwise ELB will throw error, vpc has no internet gateway)
resource "aws_internet_gateway" "gw_trf" {
  vpc_id = "${aws_vpc.vpc_trf.id}"

  tags {
    Name = "ig_trf_${random_integer.number.result}"
  }
}

#NACL applies to Subnet level while security group applies on resources inside subnet.

# Create 3 Subnets (1 - DB, 2 - Web )
resource "aws_subnet" "subnets" {
  count = "${length(var.azs)}"

  vpc_id                  = "${aws_vpc.vpc_trf.id}"
  availability_zone       = "${element(var.azs, count.index)}"
  cidr_block              = "${element(var.subnets_cidr, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "subnet_${count.index + 1}_${random_integer.number.result}"
  }
}

# Create Route Table with CIDR Block with Internet Gateway
resource "aws_route_table" "rt_trf" {
  vpc_id = "${aws_vpc.vpc_trf.id}"

  tags {
    Name = "rt_trf_${random_integer.number.result}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw_trf.id}"
  }
}

# Subnet Assoication with Route Table ( no need at NACL level)
resource "aws_route_table_association" "rt_subnet_association_trf_1" {
  subnet_id      = "${element(aws_subnet.subnets.*.id,0)}"
  route_table_id = "${aws_route_table.rt_trf.id}"
}

# Subnet Assoication with Route Table ( no need at NACL level)
resource "aws_route_table_association" "rt_subnet_association_trf_2" {
  subnet_id      = "${element(aws_subnet.subnets.*.id,1)}"
  route_table_id = "${aws_route_table.rt_trf.id}"
}

# Subnet Assoication with Route Table ( no need at NACL level)
resource "aws_route_table_association" "rt_subnet_association_trf_3" {
  subnet_id      = "${element(aws_subnet.subnets.*.id,2)}"
  route_table_id = "${aws_route_table.rt_trf.id}"
}

# Create 3 Security Groups ( 1 - ELB , 1 - Web, 1 - DB )

# Security Group - ELB
resource "aws_security_group" "sg_elb" {
  name        = "sg_elb_${random_integer.number.result}"
  description = "sg_elb_${random_integer.number.result}"
  vpc_id      = "${aws_vpc.vpc_trf.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  #
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "sg_elb_${random_integer.number.result}"
  }
}

# Security Group - Web
resource "aws_security_group" "sg_web" {
  name        = "sg_web_${random_integer.number.result}"
  description = "sg_web_${random_integer.number.result}"
  vpc_id      = "${aws_vpc.vpc_trf.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port = 80
  #   to_port   = 80
  #   protocol  = "tcp"
  #
  #   cidr_blocks = ["0.0.0.0/0"]
  #
  #   #security_groups = ["${aws_security_group.sg_elb.id}"]
  # }
  #
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "sg_web_${random_integer.number.result}"
  }
}

# Security Group - DB
resource "aws_security_group" "sg_db" {
  name        = "sg_db_${random_integer.number.result}"
  description = "sg_db_${random_integer.number.result}"
  vpc_id      = "${aws_vpc.vpc_trf.id}"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   from_port = 3389
  #   to_port   = 3389
  #   protocol  = "tcp"
  #
  #   cidr_blocks = ["0.0.0.0/0"]
  #
  #   #security_groups = ["${aws_security_group.sg_web.id}"]
  # }
  #
  # ingress {
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags {
    Name = "sg_db_${random_integer.number.result}"
  }
}

# Create DB instance in subnet #1
resource "aws_instance" "ec2_db" {
  depends_on                  = ["aws_security_group.sg_db"]
  ami                         = "ami-1853ac65"
  instance_type               = "t2.micro"
  key_name                    = "${var.lc_instance_key_pair}"
  vpc_security_group_ids      = ["${aws_security_group.sg_db.id}"]
  subnet_id                   = "${element(aws_subnet.subnets.*.id,2)}" # adding 1st subnet
  associate_public_ip_address = true

  tags {
    Name = "ec2_db_${random_integer.number.result}"
  }

  user_data = "${file("sqlScript.sh")}"
}

# Create ELB

resource "aws_elb" "ELB_TRF" {
  # elb name cannot have underscore symbol _
  name = "elb-trf-${random_integer.number.result}"

  #  availability_zones = "${var.elb_zones}"
  security_groups = ["${aws_security_group.sg_elb.id}"]
  subnets         = ["${element(aws_subnet.subnets.*.id,0)}", "${element(aws_subnet.subnets.*.id,1)}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:80/index.html"
    interval            = 5
  }

  #  instances                   = "${var.instance_list}"
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "elb-trf-${random_integer.number.result}"
  }

  depends_on = ["aws_security_group.sg_elb"]
}

# template
data "template_file" "test" {
  template = "${file("testWordPressScriptTPL.sh")}"

  vars {
    db_public_ip = "${aws_instance.ec2_db.public_ip}"
  }
}

# Create Launch Configuration
resource "aws_launch_configuration" "launch_conf" {
  depends_on                  = ["aws_elb.ELB_TRF"]
  name                        = "as_lc_trf_${random_integer.number.result}"
  image_id                    = "${var.lc_ami_image_id}"
  instance_type               = "${var.lc_instance_type}"
  security_groups             = ["${aws_security_group.sg_web.id}"]
  user_data                   = "${data.template_file.test.rendered}"
  associate_public_ip_address = true
  key_name                    = "${var.lc_instance_key_pair}"
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "as_group" {
  depends_on           = ["aws_elb.ELB_TRF"]
  name                 = "auto_scaling_${random_integer.number.result}"
  launch_configuration = "${aws_launch_configuration.launch_conf.name}"
  vpc_zone_identifier  = ["${aws_subnet.subnets.0.id}", "${aws_subnet.subnets.1.id}"]
  max_size             = "3"
  min_size             = "1"

  load_balancers = ["${aws_elb.ELB_TRF.name}"]

  tags = [
    {
      key                 = "Environment"
      value               = "dev"
      propagate_at_launch = true
    },
  ]
}
