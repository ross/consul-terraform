variable "access_key" {}

variable "secret_key" {}

variable "region" {
  default = "us-east-1"
}

variable "ssh_key" {
  default = "terraform.pem"
}

variable "key_name" {
  default = "terraform"
}

variable "availability-zone.0" {
  default = {
    us-east-1 = "us-east-1b"
    us-west-2 = "us-west-2a"
  }
}
variable "availability-zone.1" {
  default = {
    us-east-1 = "us-east-1c"
    us-west-2 = "us-west-2b"
  }
}
variable "availability-zone.2" {
  default = {
    us-east-1 = "us-east-1d"
    us-west-2 = "us-west-2c"
  }
}
