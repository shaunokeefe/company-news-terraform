# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Our default security group to access
# the instances over SSH and HTTP
resource "aws_security_group" "company_news_app" {
  name = "company_news_app"
  description = "Group for a CompanyNews app server"

  # SSH access from anywhere
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS access from anywhere
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "app-server" {
  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }

  instance_type = "t2.medium"
  ami = "${lookup(var.default_amis, var.aws_region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.company_news_app.name}"]
}

resource "aws_eip" "app-eip" {
  instance = "${aws_instance.app-server.id}"
  vpc = true
}

resource "aws_route53_zone" "primary" {
   name = "companynews.com"
}

resource "aws_route53_record" "demo-app-record" {
   zone_id = "${aws_route53_zone.primary.zone_id}"
   name = "test.companynews.com"
   type = "A"
   ttl = "300"
   records = ["${aws_eip.app-eip.public_ip}"]
}
