provider "aws" {
  profile = "default"
  region  = local.region
}

locals {
  region = "us-east-1"
  name   = "vpc-module-demo"
  tags   = var.resource_tags

}

# VPC modules block#####

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.14.2"

  name                    = local.name
  cidr                    = "10.20.0.0/16"
  instance_tenancy        = "default"
  public_subnet_suffix    = "pubs"
  private_subnet_suffix   = "priv"
  public_subnets          = ["10.20.10.0/24"]
  private_subnets         = ["10.20.100.0/24", "10.20.200.0/24"]
  azs                     = ["${local.region}a", "${local.region}b", "${local.region}c"]
  enable_dns_hostnames    = true
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true

  tags = local.tags
}

# module block for the security group

module "security-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.9.0"

  vpc_id      = module.vpc.vpc_id
  name        = local.name
  description = "module-security-group for the vpc-module-demo"
  tags        = local.tags
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ingress traffic for ssh"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "ingress traffic for the http"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      description = "egress traffic for all"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

}

# ec2 module block to create an instance in the VPC

module "ec2-instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.1"

  name                        = local.name
  ami                         = "ami-052efd3df9dad4825" #####Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-06-09#####
  associate_public_ip_address = true
  availability_zone           = "${local.region}a"
  instance_type               = "t2.micro"
  key_name                    = "loginkey"
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security-group.security_group_id]

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 10
    }
  ]

  tags = local.tags
}


module "ec2-instance-2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.1.1"

  name                        = local.name
  ami                         = "ami-052efd3df9dad4825" #####Canonical, Ubuntu, 22.04 LTS, amd64 jammy image build on 2022-06-09#####
  associate_public_ip_address = false
  availability_zone           = "${local.region}b"
  instance_type               = "t2.micro"
  key_name                    = "loginkey"
  subnet_id                   = element(module.vpc.private_subnets, 1)
  
  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 8
    }
  ]

  tags = local.tags
}

