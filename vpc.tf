terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

#*** VPC Module ***
#*** VPC ***
resource "aws_vpc" "terra-vpc" {
  cidr_block = "10.0.0.0/16"

}
#**************** Subnet Variable by using map(string) with key: Value*****************
variable "subnets_my_vpc" {
  description = "Subnet for my_vpc"
  type = map(string)
  default = { 
    "us-east-1a" = "10.0.1.0/24",
    "us-east-1b" = "10.0.2.0/24", 
    "us-east-1c" = "10.0.3.0/24"
    } 
}
#**************** Subnet & AZ Calling by using map(string) with key: Value*****************

resource "aws_subnet" "Private_Subnet" {
  vpc_id     = aws_vpc.terra-vpc.id
  for_each = var.subnets_my_vpc
  cidr_block = each.value
  availability_zone = each.key

  tags = {
    Name = each.key
    Name = each.value
  }
}

###############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terra-vpc.id

  tags = {
    Name = "Internet Gateway"
  }
}
###############################################
resource "aws_route_table" "example" {
  vpc_id = aws_vpc.terra-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }


  tags = {
    Name = "Default to internet route"
  }
}

###############################################
resource "aws_security_group" "Security_grp" {
  name        = "security_grps"
  description = "security_grps_allow443"
  vpc_id      = aws_vpc.terra-vpc.id
  tags = {
    Name = "sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound" {
  security_group_id = aws_security_group.Security_grp.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "outbound" {
  security_group_id = aws_security_group.Security_grp.id

  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 0
  ip_protocol = "tcp"
  to_port     = 0
}