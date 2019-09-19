# Asia Pacific South 1 (Mumbai) region for VPC setup
variable "aws_region" {
  description = "Region for the VPC"
  default     = "ap-south-1"
}

variable "aws_az_01" {
  description = "First Availability Zone"
  default     = "ap-south-1a"
}

variable "aws_az_02" {
  description = "Second Availability Zone"
  default     = "ap-south-1b"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "172.16.28.0/24"
}


variable "subnet_cidr" {
  default = "172.16.28.0/28"
}

variable "backup_cidr" {
  default = "172.16.28.16/28"
}

variable "db_subnet_cidr" {
  default = "172.16.28.32/28"
}

variable "coviam_ips" {
  type        = "list"
  description = "Coviam IPS"
  default     = ["182.74.255.66/32", "182.73.36.82/32"]
}


variable "db_backup_subnet_cidr" {
  default = "172.16.28.48/28"
}

# Instance type for app-server
variable "app_server_instance_type" {
  description = "Instance type for app servers"
  # there's no need for a huge machine now.  can scale up when ready
  default = "t2.xlarge"
  #default = "t2.micro"
}

# Official Centos 7 HVM image
variable "ami" {
  description = "AMI for EC2 servers"
  default     = "ami-02e60be79e78fef21"
}

# Will contain Key Path for ssh into ec2 servers
variable "public_key_path" {
  description = "SSH Public Key path"
  default     = "ssh/id_rsa.pub"
}

variable "database_username" {
  description = "Username for database"
  default     = "automi"
}

variable "database_password" {
  description = "Password for database"
  default     = "wjelthweort4ithwi04r32905uoe"
}

variable "private_key_path" {
  description = "SSH Priave key path"
  default     = "ssh/id_rsa"
}

variable "route53_zone_id" {
  description = "zone id for main automi.io domain (not tf managed)"
  default     = "Z3Q88JVAIMSGU9"
}
