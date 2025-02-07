variable "region" {
  type    = string
  default = "ca-central-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "Public_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "Private_cidr" {
  type    = string
  default = "10.0.2.0/24"
}


variable "az1" {
  type    = string
  default = "ca-central-1a"
}

variable "az2" {
  type    = string
  default = "ca-central-1b"
}


variable "ec2_ami" {
  type    = string
  default = "ami-0db18496905e01e3d"
}

variable "ec2_instance_type" {
  type    = string
  default = "t2.micro"
}