output "address" {
  value = "${aws_eip.lb-1-eip.public_ip}"
}
