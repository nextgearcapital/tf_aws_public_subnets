variable "name" { default = "public" }
variable "vpc_id" {}
variable "public_subnets" {}
variable "azs" {}
variable "environment" {}
variable "team" {}
variable "igw_id" {}

resource "aws_subnet" "public" {
  vpc_id            = "${var.vpc_id}"
  cidr_block        = "${element(split(",", var.public_subnets), count.index)}"
  availability_zone = "${element(split(",", var.azs), count.index)}"
  count             = "${length(split(",", var.public_subnets))}"

  tags {
    Name        = "${var.name}.${element(split(",", var.azs), count.index)}"
    environment = "${var.name}"
    team        = "${var.team}"
  }

  lifecycle {
    create_before_destroy = true
  }

  map_public_ip_on_launch = false
}

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${var.igw_id}"
  }

  tags {
    Name = "${var.name}.${element(split(",", var.azs), count.index)}"
    environment = "${var.name}"
    team        = "${var.team}"
  }
}

resource "aws_route_table_association" "public" {
  count          = "${length(split(",", var.cidrs))}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

output "subnet_ids" {
  value = "${join(",", aws_subnet.public.*.id)}"
}
