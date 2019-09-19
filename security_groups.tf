# there is an open terraform issue about security group modifications
#  https://github.com/terraform-providers/terraform-provider-aws/issues/265
# if certain attributes in a security group change (like name or description) terraform deletes it and recreates it
# if a security group is attached to an instance (or other resouces) aws doesn't let it get deleted
# terraform is too stupid to detect that condition, so it just hangs forever on deleting the security group
# adding "lifecycle { create_before_destroy = true }" makes it create a new group before deleting the old one
# and using name_prefix (instead of name) lets it actually create the new group w/ a unique name, then delete the old one
# my hatred for this pattern is high, but i don't know of any other solution

resource "aws_security_group" "ssh" {

  name_prefix = "ssh-"
  description = "Allow incoming ssh connections."
  lifecycle { create_before_destroy = true }


  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # should lock this down to just coviam IP's
    # but internet connection is IPv6, and our VPN doesn't support IPv6 yet
    cidr_blocks = concat(var.coviam_ips, ["0.0.0.0/0"])
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${local.environment}: allow ssh"
  }
}

resource "aws_security_group" "web" {
  name_prefix = "web-"
  description = "Allow HTTP connections on 80 and 443"
  lifecycle { create_before_destroy = true }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${local.environment}: web"
  }

}

resource "aws_security_group" "node_exporter" {
  name_prefix = "node_exporter"
  description = "Allow ports 9100 for node exporter"
  lifecycle { create_before_destroy = true }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${local.environment}: node_exporter"
  }

}

resource "aws_security_group" "kafka_exporter" {
  name_prefix = "kafka_exporter"
  description = "To scrape the kafka exporter metrics"
  lifecycle { create_before_destroy = true }

  ingress {
    from_port   = 9308
    to_port     = 9308
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${local.environment}: kafka_exporter"
  }

}

resource "aws_security_group" "infra" {
  name_prefix = "infra-"
  description = "Allow ports 9090  and 3000 for promethus and grafana"
  lifecycle { create_before_destroy = true }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.coviam_ips
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.coviam_ips
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${local.environment}: infra"
  }

}

resource "aws_security_group" "internal_web_apps" {
  name_prefix = "internal-web-apps-"
  description = "Allow HTTP connections on 8010 and 8015"
  lifecycle { create_before_destroy = true }


  ingress {
    from_port   = 8010
    to_port     = 8010
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    from_port   = 8015
    to_port     = 8015
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${local.environment}: internal web apps"
  }

}

resource "aws_security_group" "internet_access" {
  name_prefix = "internet-access-"
  description = "Allow connections to the internet"
  lifecycle { create_before_destroy = true }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "${local.environment}: internet access"
  }

}

resource "aws_security_group" "rds" {
  name_prefix = "rds-"
  lifecycle { create_before_destroy = true }
  description = "RDS security group"
  vpc_id      = "${aws_vpc.vpc.id}"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${aws_vpc.vpc.cidr_block}"]
  }
}
