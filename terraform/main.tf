provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

module "vpc" {
  source = "./modules/vpc"
}

module "subnet_a" {
  source = "./modules/subnet"
  vpc_id = module.vpc.id
  cidr   = "10.0.1.0/24"
  az     = data.aws_availability_zones.available.names[0]
  name                  = "subnet-a"
  public                = true
  public_route_table_id = module.vpc.public_route_table_id
}

module "subnet_b" {
  source = "./modules/subnet"
  vpc_id = module.vpc.id
  cidr   = "10.0.2.0/24"
  az     = data.aws_availability_zones.available.names[1]
  name                  = "subnet-b"
  public                = true
  public_route_table_id = module.vpc.public_route_table_id
}

module "security" {
  source           = "./modules/security"
  vpc_id           = module.vpc.id
  ssh_allowed_cidr = var.ssh_allowed_cidr
}

module "control_plane" {
  source            = "./modules/ec2"
  name              = "control-plane"
  ami               = data.aws_ssm_parameter.ami.value
  subnet_id         = module.subnet_a.id
  security_group_id = module.security.nodes_sg_id
  key_name          = var.key_name
  instance_type     = "t3.small"
  public_ip         = true
}

module "worker_1" {
  source            = "./modules/ec2"
  name              = "worker-1"
  ami               = data.aws_ssm_parameter.ami.value
  subnet_id         = module.subnet_a.id
  security_group_id = module.security.nodes_sg_id
  key_name          = var.key_name
  instance_type     = "t3.small"
  public_ip         = true
}

module "worker_2" {
  source            = "./modules/ec2"
  name              = "worker-2"
  ami               = data.aws_ssm_parameter.ami.value
  subnet_id         = module.subnet_b.id
  security_group_id = module.security.nodes_sg_id
  key_name          = var.key_name
  instance_type     = "t3.small"
  public_ip         = true
}

module "bastion" {
  source            = "./modules/ec2"
  name              = "bastion"
  ami               = data.aws_ssm_parameter.ami.value
  subnet_id         = module.subnet_a.id
  security_group_id = module.security.bastion_sg_id
  key_name          = var.key_name
  public_ip         = true
}
