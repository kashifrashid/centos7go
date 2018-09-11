module "bitcoin_sv_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "bitcoin_sv_sg"
  description = "bitcoin_sv  from within vpc"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  ingress_rules       = ["ssh-tcp","all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 8332
      to_port     = 8333
      protocol    = "tcp"
      description = "User-service ports (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    },
    {
    
      from_port   = 28332
      to_port     = 28333
      protocol    = "tcp"
      description = "User-service ports (ipv4)"
      cidr_blocks = "0.0.0.0/0"
    },
  ]
  egress_rules        = ["all-all"]
  create = "${var.bitcoin_sv_instance_count == 0 ? false : true }"
}

module "ec2_bitcoin_sv" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = "${var.bitcoin_sv_instance_count}"

  name                        = "maestro-bitcoin_sv"
  ami                         = "${var.ami_id}"
  instance_type               = "t3.2xlarge"
  associate_public_ip_address = true
  subnet_id                   = "${element(module.vpc.public_subnets, 0)}"
  vpc_security_group_ids      = ["${module.bitcoin_sv_security_group.this_security_group_id}"]
  key_name                    = "svpoolkey"
  user_data                   = "${file("userdata.sh")}"
  root_block_device           = [{ 
                                  volume_type           = "gp2"
                                  volume_size           = "2048"
                                  delete_on_termination = "true" # change to false in final
                                }]

  tags {
    Owner       = "svpool"
    Environment = "alpha"
    DeployFrom = "terraform"
  }
}
