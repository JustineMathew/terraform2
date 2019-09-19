resource "aws_db_instance" "rds-database" {
  allocated_storage           = 10
  max_allocated_storage       = 100
  storage_type                = "gp2"
  engine                      = "mariadb"
  engine_version              = "10.2"
  identifier                  = "${local.environment}"
  instance_class              = "db.t3.large"
  username                    = "${var.database_username}"
  password                    = "${var.database_password}"
  allow_major_version_upgrade = true
  backup_retention_period     = 1
  db_subnet_group_name        = "${aws_db_subnet_group.database_subnet_group.id}"
  skip_final_snapshot         = true
  vpc_security_group_ids      = ["${aws_security_group.rds.id}", "${aws_security_group.internet_access.id}", "${aws_security_group.node_exporter.id}"]
}

resource "aws_db_subnet_group" "database_subnet_group" {
  name       = "${local.environment}-db-subnet-group"
  subnet_ids = ["${aws_subnet.db_subnet.id}", "${aws_subnet.db_subnet_backup.id}"]

  tags = {
    Name = "${local.environment}: DB subnet group"
  }
}

# internal DNS name for the app server
resource "aws_route53_record" "database" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "database"
  type    = "CNAME"
  ttl     = "300"
  records = ["${aws_db_instance.rds-database.address}"]
}
