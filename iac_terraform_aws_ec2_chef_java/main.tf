provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_instance" "web-server" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_pair_name}"
  security_groups = ["${aws_security_group.default_allow_all_sg.name}"]
  tags {
    Name = "web-server"
  }
}

resource "aws_security_group" "default_allow_all_sg" {
  name        = "default_allow_all_sg"
  description = "Allow all inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = ["pl-12c4e678"]
  }

  tags {
    Name = "allow_all"
  }
}