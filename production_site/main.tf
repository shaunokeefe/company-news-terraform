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

resource "aws_instance" "app-server-1" {
  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }
  instance_type = "t2.small"
  ami = "ami-47587629"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.company_news_app.name}"]
  private_ip = "172.31.24.20"
}

resource "aws_instance" "app-server-2" {
  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }
  instance_type = "t2.small"
  ami = "ami-47587629"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.company_news_app.name}"]
  private_ip = "172.31.24.21"
}

resource "aws_instance" "load-balancer-1" {
  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }
  instance_type = "t2.small"
  ami = "ami-562b0538"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.company_news_lb.name}"]
  user_data = "${file("lb_userdata.sh")}"


resource "aws_instance" "load-balancer-2" {
  connection {
    user = "ubuntu"
    key_file = "${var.key_path}"
  }
  instance_type = "t2.small"
  ami = "ami-562b0538"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.company_news_lb.name}"]
  user_data = "${file("lb_userdata.sh")}"
}
}
