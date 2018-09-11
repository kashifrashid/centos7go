

# Variable to setup ENV

variable "cidr_begin" {
	type ="string"
  default = "10.16"
}

variable "ami_id" {
  type = "string"
  default = "ami-02e9de901affd60e8"
  description = "CentOS Linux 7 x86_64 HVM EBS ENA 1805_01-b7ee8a69-ee97-4a49-9e68-afaee216db2e-ami-77ec9308.4 (ami-00846a67)"
}

variable "aws_region" {
  type ="string"
  default = "eu-west-2"
}

variable "key_name" {
  type ="string"
  default = "svpoolkey"

}

variable "stratum_instance_count" {
   default =  2
}

# influlxdb instance 
variable "influxdb_instance_count" {
  default = 2
}
variable "inflixdb_disk_sze" {
  default = 1024 # 1 TB
}

variable "data_disk_iops" {
  default = 6000
}

variable "disk_device_name" {
  default = "/dev/xvdh"
}

# Postgres  instance info

variable "postgres_instance_count" {
  default = 2
}

variable "maestro_instance_count" {
  default = 2
}

variable "dashboard_instance_count" {
  default = 2
}

variable "monitoring_instance_count" {
  default = 2
}

variable "logging_instance_count" {
  default = 2
}

variable "jdispacher_instance_count" {
  default = 4  
}

variable "bitcoin_sv_instance_count" {
  default = 2
}

variable "list_ips_public" {
  type = "list"
  default = ["213.1.222.235/32"]
}
