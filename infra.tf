resource "aws_instance" "infra" {


  ami           = var.ami
  instance_type = "t2.medium"
  key_name      = aws_key_pair.default.id
  subnet_id     = aws_subnet.subnet.id

  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.infra.id}", "${aws_security_group.node_exporter.id}", "${aws_security_group.internet_access.id}"]

  tags = {
    Name = "${local.environment}: infra"
  }

}

resource "aws_eip" "infra_ip" {
  instance = "${aws_instance.infra.id}"
  vpc      = true
}

# public DNS name for the infra server
resource "aws_route53_record" "infra" {
  zone_id = var.route53_zone_id
  name    = "${local.environment}-infra"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.infra_ip.public_ip}"]
}

# internal DNS name for the infra server
resource "aws_route53_record" "infra_private" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "infra"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.infra.private_ip}"]
}
