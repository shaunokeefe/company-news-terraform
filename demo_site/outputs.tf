output "address" {
  value = "${aws_instance.app-server.public_dns}"
}
