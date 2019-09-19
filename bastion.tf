resource "aws_instance" "bastion" {

  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = aws_key_pair.default.id

  # we only use the public ip during provisioning
  # the rest of the time, we'll use the EIP
  # the issue is a cyclic dependency:
  # - you can't finish provisioning the instance unless you can connect to it
  # - ideally you connect for provisioning using the EIP, but you can't assoicated the EIP till the the instance is provisioned
  # - hence you need a public ip, so you can provision, so you can assoicate the EIP
  associate_public_ip_address = true

  source_dest_check      = false
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = ["${aws_security_group.ssh.id}", "${aws_security_group.internet_access.id}", "${aws_security_group.node_exporter.id}"]

  tags = {
    Name = "${local.environment}: bastion"
  }

  connection {
    type        = "ssh"
    user        = "centos"
    host        = self.public_ip
    private_key = "${file(var.private_key_path)}"
  }

  provisioner "file" {
    source      = "${var.private_key_path}"
    destination = "~/.ssh/id_rsa"

  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 ~/.ssh/id_rsa",
    ]
  }

}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

# public DNS name for the bastion server
resource "aws_route53_record" "bastion" {
  zone_id = var.route53_zone_id
  name    = "${local.environment}-bastion"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.bastion.public_ip}"]
}

# internal DNS name for the bastion server
resource "aws_route53_record" "bation_private" {
  zone_id = "${aws_route53_zone.internal.zone_id}"
  name    = "bastion"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion.private_ip}"]
}
