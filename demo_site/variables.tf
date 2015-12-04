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

# Ubuntu Precise 14.04 LTS (x64)
variable "default_amis" {
  default = {
    ap-northeast-1 = "ami-1f80af71"
    ap-southeast-2 = "ami-69631053"
  }
}
