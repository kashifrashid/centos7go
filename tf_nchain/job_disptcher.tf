module "jdispacher_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "jdispacher_sg"
  description = "jdispacher  from within vpc"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  ingress_rules       = ["ssh-tcp","all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 9995
      to_port     = 9995
      protocol    = "tcp"
      description = "User-service ports (ipv4)"
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    },
  ]
  egress_rules        = ["all-all"]
}

module "ec2_jdispacher" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = "${var.jdispacher_instance_count}"

  name                        = "maestro-jdispacher"
  ami                         = "${var.ami_id}"
  instance_type               = "t3.2xlarge"
  subnet_id                   = "${element(module.vpc.private_subnets, 0)}"
  vpc_security_group_ids      = ["${module.jdispacher_security_group.this_security_group_id}"]
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
