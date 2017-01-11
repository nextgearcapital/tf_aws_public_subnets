variable "name" { default = "public" }
variable "vpc_id" {}
variable "public_subnets" {}
variable "azs" {}
variable "environment" {}
variable "team" {}

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
