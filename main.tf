#------------------------------------------------------------------------------
# Consul Servers
#------------------------------------------------------------------------------

resource "aws_security_group" "consul-server" {
  name = "consul server"
  description = "Network access control for the consul server role"
  vpc_id = "${aws_vpc.primary.id}"

  # NOTE: you'd never want to have any public access to these hosts in a real
  # setup

  # ssh in from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # this should only be allowed from a bastion host in a real setup
    cidr_blocks = ["0.0.0.0/0"]
  }

  # server rpc
  ingress {
    from_port = 8300
    to_port = 8300
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 8300
    to_port = 8300
    protocol = "udp"
    self = true
  }
  # serf lan
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 8301
    to_port = 8301
    protocol = "udp"
    self = true
  }
  # serf wan
  ingress {
    from_port = 8302
    to_port = 8302
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 8302
    to_port = 8302
    protocol = "udp"
    self = true
  }
  # consul dns
  ingress {
    from_port = 8600
    to_port = 8600
    protocol = "udp"
    self = true
  }
  # consul http
  ingress {
    from_port = 8500
    to_port = 8500
    protocol = "tcp"
    # this should not be public in a "real" setup
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8500
    to_port = 8500
    protocol = "udp"
    self = true
  }
  # rpc
  ingress {
    from_port = 8400
    to_port = 8400
    protocol = "tcp"
    self = true
  }
  ingress {
    from_port = 8400
    to_port = 8400
    protocol = "udp"
    self = true
  }

  # everything out
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "consul-server" {
  ami = "${lookup(var.amis-hvm, var.region)}"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${element(aws_subnet.primary-public.*.id, count.index)}"
  vpc_security_group_ids = ["${aws_security_group.consul-server.id}"]

  tags = {
    Name = "consul-server-${format("%06d", count.index)}"
  }

  # don't use provisioners for anything real, they seem flaky
  connection {
    user = "ubuntu"
    key_file = "${var.ssh_key}"
  }

  provisioner "file" {
    source = "consul-server-setup.sh"
    destination = "/home/ubuntu/consul-server-setup.sh"
  }

  provisioner "file" {
    source = "consul-upstart.conf"
    destination = "/home/ubuntu/consul-upstart.conf"
  }

  provisioner "remote-exec" {
    inline = ["bash /home/ubuntu/consul-server-setup.sh ${self.tags.Name} ${var.region}"]
  }

  count = 2
}

# this copy-n-paste is so that i can hack in a couple extra commands on the
# third instance to get it to join the others. you'd never do it this way if
# you had a real setup with configuration management. it'd just be count = 3
resource "aws_instance" "consul-server2" {
  ami = "${lookup(var.amis-hvm, var.region)}"
  associate_public_ip_address = true
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  subnet_id = "${element(aws_subnet.primary-public.*.id, 2)}"
  vpc_security_group_ids = ["${aws_security_group.consul-server.id}"]

  tags = {
    Name = "consul-server-${format("%06d", 2)}"
  }

  # don't use provisioners for anything real, they seem flaky
  connection {
    user = "ubuntu"
    key_file = "${var.ssh_key}"
  }

  provisioner "file" {
    source = "consul-server-setup.sh"
    destination = "/home/ubuntu/consul-server-setup.sh"
  }

  provisioner "file" {
    source = "consul-upstart.conf"
    destination = "/home/ubuntu/consul-upstart.conf"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /home/ubuntu/consul-server-setup.sh ${self.tags.Name} ${var.region}",
      "sleep 10",
      "/home/consul/bin/consul join ${aws_instance.consul-server.0.private_ip} ${aws_instance.consul-server.1.private_ip}"
    ]
  }
}

resource "aws_eip" "consul-server" {
  instance = "${element(aws_instance.consul-server.*.id, count.index)}"
  vpc = true

  count = 2
}

resource "aws_eip" "consul-server2" {
  instance = "${aws_instance.consul-server2.id}"
  vpc = true
}
