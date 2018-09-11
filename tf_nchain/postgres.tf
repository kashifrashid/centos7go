
module "postgres_security_group" {
  source = "terraform-aws-modules/security-group/aws"
  name        = "postgres_sg"
  description = "postgres from within vpc"
  vpc_id      = "${module.vpc.vpc_id}"

  ingress_cidr_blocks = ["${module.vpc.vpc_cidr_block}"]
  ingress_rules       = ["ssh-tcp","all-icmp"]
  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "User-service ports (ipv4)"
      cidr_blocks = "${module.vpc.vpc_cidr_block}"
    },
  ]
  egress_rules        = ["all-all"]
}


module "ec2_postgres" {
  source = "terraform-aws-modules/ec2-instance/aws"
  instance_count = "${var.postgres_instance_count}"

  name                        = "influxdb"
  ami                         = "${var.ami_id}"
  instance_type               = "t3.2xlarge"
  subnet_id                   = "${element(module.vpc.private_subnets, 0)}"
  vpc_security_group_ids      = ["${module.postgres_security_group.this_security_group_id}"]
  key_name                    = "svpoolkey"
#   user_data                   = "${file("userdata_influxdb.sh")}"
  root_block_device           = [{ 
                                  volume_type           = "gp2"
                                  volume_size           = "100"
                                  delete_on_termination = "true" # change to false in final
                                }]

  tags {
    Owner       = "svpool"
    Environment = "alpha"
    DeployFrom = "terraform"
  }
}


resource "aws_ebs_volume" "postgres_vol" {
    availability_zone = "${var.aws_region}a"
    size              = "${var.inflixdb_disk_sze}"
    encrypted         = true
    type              = "gp2"
    iops              = "100"
    availability_zone = "${var.aws_region}a"
    count             = "${var.postgres_instance_count}"
 
    tags {
            name = "postgres"
         }
}


resource "aws_volume_attachment" "postgres_vol_attach" {
    device_name = "${var.disk_device_name}"
    volume_id   = "${aws_ebs_volume.postgres_vol.*.id[count.index]}"
    instance_id = "${module.ec2_postgres.id[count.index]}"
    count       = "${var.postgres_instance_count}"
    force_detach = true
}
