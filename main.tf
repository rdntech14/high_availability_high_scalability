provider "aws" {
  region = "${var.AWS_REGION}"
}

# Generate Random Number
resource "random_integer" "number" {
  min = 11111
  max = 99999
}

# Create vpc
resource "aws_vpc" "vpc_trf" {
  cidr_block = "${var.vpc_cidr}"

  tags {
    Name = "vpc_trf_${random_integer.number.result}"
  }
}

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

# Create 3 Security Groups ( 1 - ELB , 1 - Web, 1 - DB )

# Security Group - ELB
resource "aws_security_group" "sg_elb" {
  name        = "sg_elb_${random_integer.number.result}"
  description = "sg_elb_${random_integer.number.result}"
  vpc_id      = "${aws_vpc.vpc_trf.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.sg_elb.id}"]

    #    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
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
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"

    # cidr_blocks = ["0.0.0.0/0"]
    security_groups = ["${aws_security_group.sg_web.id}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

# # Create DB instance
# resource "aws_instance" "ec2_db" {
#   ami           = "ami-1853ac65"
#   instance_type = "t2.micro"
#   key_name      = "ec2_keyPair"
#   subnet_id     = "${aws_subnet.subnets.id}"
#
#   tags {
#     Name = "ec2_db_${random_integer.number.result}"
#   }
#
#   user_data = "${file("sqlScript.sh")}"
# }

