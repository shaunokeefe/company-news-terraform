output "address" {
  value = "${aws_eip.app-eip.public_ip}"
}
