provider "aws" {
  region = "eu-west-2"
}

variable "number_of_instances" {
  description = "Number of instances to create and attach to ELB"
  default     = 1
}


module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "test_vpc"

  cidr = "10.10.0.0/16"

  azs               = ["eu-west-2a", "eu-west-2b"]
  public_subnets    = ["10.10.1.0/24", "10.10.1.0/24"]

  tags = {
    Owner       = "kash"
    Environment = "testing"
  }
}

module "ba_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "ssh"
  description = "ssh from anywhere"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp","all-icmp"]
  egress_rules        = ["all-all"]
}

# module "ht_security_group" {
#   source = "terraform-aws-modules/security-group/aws"
#   name        = "http"
#   description = "http from anywhere"
#   vpc_id      = "${module.vpc.vpc_id}"

#   ingress_cidr_blocks = ["0.0.0.0/0"]
#   ingress_rules       = ["http-tcp","all-icmp"]
#   egress_rules        = ["all-all"]
# }



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
  subnet_id                   = "${module.vpc.public_subnets}"
  vpc_security_group_ids      = ["${module.ba_security_group.this_security_group_id}"]
  key_name                    = "svpoolkey"
  user_data                   = "${file("userdata.sh")}"

  tags {
    Owner       = "sc"
    Environment = "test"
    DeployFrom = "terraform"
  }
}


# ######
# # ELB
# # ######
# module "http_elb" {
#   source  = "terraform-aws-modules/elb/aws"
#   version = "1.4.1"

#   name = "elb-example"

#   subnets         = ["${module.vpc.public_subnets}"]
#   security_groups = ["${module.ha_security_group.this_security_group_id}"]
#   internal        = false

#   listener = [
#     {
#       instance_port     = "80"
#       instance_protocol = "HTTP"
#       lb_port           = "80"
#       lb_protocol       = "HTTP"
#     },
#     {
#       instance_port     = "8080"
#       instance_protocol = "HTTP"
#       lb_port           = "8080"
#       lb_protocol       = "HTTP"
#     },
#   ]

#   health_check = [
#     {
#       target              = "HTTP:80/"
#       interval            = 30
#       healthy_threshold   = 2
#       unhealthy_threshold = 2
#       timeout             = 5
#     },
#   ]

#   // Uncomment this section and set correct bucket name to enable access logging
#   //  access_logs = [
#   //    {
#   //      bucket = "my-access-logs-bucket"
#   //    },
#   //  ]

#   tags = {
#     Owner       = "user"
#     Environment = "dev"
#   }
#   # ELB attachments
#   number_of_instances = "${var.number_of_instances}"
#   instances           = ["${module.ec2_instances.id}"]
# }


# module "elb" {
#   source = "./modules/elb/"
#   name = "elb-example"

#   subnets         = ["subnet-12345678", "subnet-87654321"]
#   security_groups = ["sg-12345678"]
#   internal        = false

#   listener = [
#     {
#       instance_port     = "80"
#       instance_protocol = "HTTP"
#       lb_port           = "80"
#       lb_protocol       = "HTTP"
#     },
#   ]

#   health_check = [
#     {
#       target              = "HTTP:80/"
#       interval            = 30
#       healthy_threshold   = 2
#       unhealthy_threshold = 2
#       timeout             = 5
#     },
#   ]

#   access_logs = [
#     {
#       bucket = "my-access-logs-bucket"
#     },
#   ]

#   // ELB attachments
#   number_of_instances = 1
#   instances           = ["${module.ec2_instances.id}"]

#   tags = {
#     Owner       = "user"
#     Environment = "dev"
#   }
# }