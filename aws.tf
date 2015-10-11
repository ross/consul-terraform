provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

variable "amis-hvm" {
  default = {
    us-east-1 = "ami-d05e75b8"
    us-west-2 = "ami-5189a661"
  }
}
variable "amis-pv" {
  default = {
    us-east-1 = "ami-d85e75b0"
    us-west-2 = "ami-6989a659"
  }
}
