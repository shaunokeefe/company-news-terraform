variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "key_path" {
  description = "Path to the private portion of the SSH key specified."
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default = "ap-northeast-1"
}

variable "lb_amis" {
  default = {
    ap-northeast-1 = "ami-562b0538"
    ap-southeast-2 = "ami-69631053"
  }
}

variable "app_amis" {
  default = {
    ap-northeast-1 = "ami-47587629"
    ap-southeast-2 = "ami-69631053"
  }
}

variable "app_ips" {
  default = {
    "0" = "172.31.24.20"
    "1" = "172.31.24.21"
    "2" = "172.31.24.22"
  }
}
