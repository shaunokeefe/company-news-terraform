output "address" {
  value = "${aws_instance.load-balancer-1.public_dns}"
}
