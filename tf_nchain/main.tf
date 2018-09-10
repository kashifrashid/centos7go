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

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp","all-icmp"]
  egress_rules        = ["all-all"]
}



# 30 private instaance 

# 12 maestro-stratum-1
# 2  postgres-1
# 2 influxdb
# 2 maestro-shares
# 2 dashboard
# 2 monitoring
# 4 job dispacher
# 2 logging
# 2 bitcoin-sv


data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"
    values = [ "amzn-ami-hvm-*-x86_64-gp2", ]
  }

  filter {
    name = "owner-alias"
    values = [ "amazon" ]
  }
}


module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = 1

  name                        = "bastion-instance"
  ami                         = "${data.aws_ami.amazon_linux.id}"
  associate_public_ip_address = true
  instance_type               = "t2.micro"
  subnet_id                   = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids      = ["${module.ba_security_group.this_security_group_id}"]
  key_name                    = "svpoolkey"
  user_data                   = "${file("userdata.sh")}"

  tags {
    Owner       = "svpool"
    Environment = "alpha"
    DeployFrom = "terraform"
  }
}


# m5d.2xlarge   postgres
# influx m5d.2xlarge

module "ec2_postgres" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = "${var.stratum_instance_count}"

  name                        = "postgres"
  ami                         = "${var.ami_id}"
  instance_type               = "t3.2xlarge"
  subnet_id                   = "${element(module.vpc.private_subnets, 0)}"
  vpc_security_group_ids      = ["${module.stratun_security_group.this_security_group_id}"]
  key_name                    = "svpoolkey"
  user_data                   = "${file("userdata.sh")}"
  root_block_device           = [{ 
                                  volume_type           = "gp2"
                                  volume_size           = "1024"
                                  delete_on_termination = "true" # change to false in final
                                }]

  tags {
    Owner       = "svpool"
    Environment = "alpha"
    DeployFrom = "terraform"
  }
}
