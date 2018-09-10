module "stratun_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "stratun_sg"
  description = "stratun  from within vpc"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  ingress_rules       = ["ssh-tcp","all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9999
      to_port     = 9999
      protocol    = "tcp"
      description = "User-service ports (ipv4)"
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    },
  ]
  egress_rules        = ["all-all"]
}

module "stratun_security_group_elb" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "stratun_elb_sg"
  description = "stratun  from 3333 to vpc"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_with_cidr_blocks = [
    {
      from_port   = 3333
      to_port     = 3333
      protocol    = "tcp"
      description = "User-service ports (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules        = ["all-all"]
}

module "ec2_stratum" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = "${var.stratum_instance_count}"

  name                        = "maestro-stratum"
  ami                         = "${var.ami_id}"
  instance_type               = "t3.2xlarge"
  subnet_id                   = "${element(module.vpc.private_subnets, 0)}"
  vpc_security_group_ids      = ["${module.stratun_security_group.this_security_group_id}"]
  key_name                    = "svpoolkey"
  user_data                   = "${file("userdata_stratum.sh")}"
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


resource "aws_elb" "stratum_elb" {
  name = "stratum-elb"

  subnets         = ["${element(module.vpc.public_subnets, 0)}"]
  security_groups = ["${module.stratun_security_group_elb.this_security_group_id}"]
  instances       = ["${module.ec2_stratum.id}"]

  listener {
    instance_port     = 9999
    instance_protocol = "tcp"
    lb_port           = 3333
    lb_protocol       = "tcp"
  }
}