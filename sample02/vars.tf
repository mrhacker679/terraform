variable "region" {
  default = "us-east-1"
}

variable "vpc-cidr" {
  default = "10.10.0.0/16"
}

variable "azs" {
  type = list
  default = ["us-east-1a" , "us-east-1b", "us-east-1c"]
}

variable "private-subnets" {
  type = list
  default = ["10.10.1.0/24" , "10.10.2.0/24" , "10.10.3.0/24"]
}
variable "public-subnets" {
  type = list
  default = ["10.10.20.0/24" , "10.10.21.0/24" , "10.10.22.0/24"]
}
