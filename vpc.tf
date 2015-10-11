#------------------------------------------------------------------------------
# vpc
#------------------------------------------------------------------------------

resource "aws_vpc" "primary" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "primary"
  }
}

#------------------------------------------------------------------------------
# public subnets
#------------------------------------------------------------------------------

resource "aws_internet_gateway" "primary-gateway" {
  vpc_id = "${aws_vpc.primary.id}"
}

resource "aws_route_table" "primary-public" {
  vpc_id = "${aws_vpc.primary.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.primary-gateway.id}"
  }
}

resource "aws_subnet" "primary-public" {
  availability_zone = "${lookup(format("availability-zone.%d", count.index), var.region)}"
  cidr_block = "10.0.${count.index + 100}.0/24"
  map_public_ip_on_launch = true
  vpc_id = "${aws_vpc.primary.id}"

  tags {
    Name = "Primary Public ${count.index}"
  }

  count = 3
}

resource "aws_route_table_association" "route-assocation-public" {
  subnet_id = "${element(aws_subnet.primary-public.*.id, count.index)}"
  route_table_id = "${aws_route_table.primary-public.id}"

  count = 3
}
