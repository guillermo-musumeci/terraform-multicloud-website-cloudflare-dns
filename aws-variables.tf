# aws-variables.tf | Variables for the AWS module

# AWS authentication variables
variable "aws_access_key" {
  type = string
  description = "AWS Access Key"
}

variable "aws_secret_key" {
  type = string
  description = "AWS Secret Key"
}

variable "aws_key_pair" {
  type = string
  description = "AWS Key Pair"
}

# AWS Region
variable "aws_region" {
  type = string
  description = "AWS Region for the VPC"
  default = "eu-west-1"
}

# AWS AZ
variable "aws_az" {
  type = string
  description = "AWS AZ"
  default = "eu-west-1c"
}

# VPC Variable
variable "aws_vpc_cidr" {
  type = string
  description = "CIDR for the VPC"
  default = "10.1.0.0/16"
}

# Subnet Variable
variable "aws_subnet_cidr" {
  type = string
  description = "CIDR for the subnet"
  default = "10.1.1.0/24"
}
