provider "aws" {
  region = "${var.aws_region}"
}

terraform {
  backend "s3" {
    bucket = "svpoolterraformtstate"
    key    = "svpoolalphabui/svpool.tfstate"
    region = "eu-west-2"
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  name = "svpool_vpc"

  cidr = "${var.cidr_begin}.0.0/16"

  azs                 = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets     = ["${var.cidr_begin}.0.0/20", "${var.cidr_begin}.16.0/20", "${var.cidr_begin}.32.0/20"]
  public_subnets      = ["${var.cidr_begin}.48.0/20", "${var.cidr_begin}.64.0/20", "${var.cidr_begin}.80.0/20"]
  
  enable_dns_hostnames = true
  enable_dns_support = true

  enable_nat_gateway = true
  single_nat_gateway = true
 
  tags = {
    Owner       = "svpool"
    Environment = "alpha"
    Name        = "svpool-${var.cidr_begin}_16"
  }
}


# create sg for bastio box

module "ba_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "ssh_bastion"
  description = "ssh from anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = "${var.list_ips_public}"
  ingress_rules       = ["ssh-tcp","all-icmp"]
  egress_rules        = ["all-all"]
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
    }

    filter {
        name   = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] # Canonical
}

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = 1
  name                        = "bastion-instance"
  ami                         = "${data.aws_ami.ubuntu.id}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids      = ["${module.ba_security_group.this_security_group_id}"]
  key_name                    = "svpoolkey"
  # user_data                   = "${file("ububnut.sh")}"

  tags {
    Owner       = "svpool"
    Environment = "alpha"
    DeployFrom = "terraform"
  }
}


# m5d.2xlarge   postgres
# influx m5d.2xlarge
