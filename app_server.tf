resource "aws_instance" "app_server" {

  ami                         = var.ami
  instance_type               = var.app_server_instance_type
  key_name                    = aws_key_pair.default.id
  associate_public_ip_address = true

  source_dest_check = false
  subnet_id         = aws_subnet.subnet.id
  # will likely need to add a security group that allows
  # from everything on the same subnet, but there's nothing else for now
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.internet_access.id}", "${aws_security_group.internal_web_apps.id}", "${aws_security_group.node_exporter.id}", "${aws_security_group.kafka_exporter.id}"]

  tags = {
    Name = "${local.environment}: App Server"
  }

  connection {
    type        = "ssh"
    user        = "centos"
    host        = self.public_ip
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y epel-release",
      "sudo yum install -y python-pip",
      "sudo pip install awscli"
    ]
  }

}


# public DNS name for the bastion server
resource "aws_route53_record" "app_server" {
  zone_id = var.route53_zone_id
  name    = "${local.environment}-appserver"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.app_server.public_ip}"]
}

# internal DNS name for the app server
resource "aws_route53_record" "appserver_private" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "app"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.app_server.private_ip}"]
}
