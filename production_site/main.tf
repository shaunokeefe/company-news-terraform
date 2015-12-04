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

  # access to tomcat HTTP port from the LB
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = ["${aws_security_group.company_news_lb.id}"]
  }

  # access to tomcat HTTP port from the LB
  ingress {
    from_port = 8443
    to_port = 8443
    protocol = "tcp"
    security_groups = ["${aws_security_group.company_news_lb.id}"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "company_news_lb" {
  name = "company_news_lb"
  description = "Group for a CompanyNews load balancer"

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
  ami = "${lookup(var.app_amis, var.aws_region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.company_news_app.name}"]
  count = 3
}

resource "template_file" "lb_userdata" {
  filename = "lb_userdata.sh"
  vars {
    ip0 = "${aws_instance.app-server.0.private_ip}"
    ip1 = "${aws_instance.app-server.1.private_ip}"
    ip2 = "${aws_instance.app-server.2.private_ip}"
  }
}

resource "aws_instance" "load-balancer-1" {
  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }
  instance_type = "t2.medium"
  ami = "${lookup(var.lb_amis, var.aws_region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.company_news_lb.name}"]
  user_data =  "${template_file.lb_userdata.rendered}"}

resource "aws_eip" "lb-1-eip" {
  instance = "${aws_instance.load-balancer-1.id}"
  vpc = true
}

resource "aws_instance" "load-balancer-2" {
  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }
  instance_type = "t2.medium"
  ami = "${lookup(var.lb_amis, var.aws_region)}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.company_news_lb.name}"]
  user_data = "${file("lb_userdata.sh")}"
}

resource "aws_route53_zone" "primary" {
   name = "companynews.com"
}

resource "aws_route53_record" "tld" {
   zone_id = "${aws_route53_zone.primary.zone_id}"
   name = "companynews.com"
   type = "A"
   ttl = "300"
   records = ["${aws_eip.lb-1-eip.public_ip}"]
}

resource "aws_route53_record" "www" {
   zone_id = "${aws_route53_zone.primary.zone_id}"
   name = "www.companynews.com"
   type = "A"
   ttl = "300"
   records = ["${aws_eip.lb-1-eip.public_ip}"]
}

resource "aws_s3_bucket" "static-resources-s3" {
    bucket = "static.companynews.com"
    acl = "public-read"
}
