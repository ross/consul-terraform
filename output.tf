
output "consul-server.0" {
  value = "${aws_eip.consul-server.0.public_ip}"
}
output "consul-server.1" {
  value = "${aws_eip.consul-server.1.public_ip}"
}
output "consul-server2" {
  value = "${aws_eip.consul-server2.public_ip}"
}
