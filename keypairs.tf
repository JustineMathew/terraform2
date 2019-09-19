resource "aws_key_pair" "default" {
  key_name   = "default-keypair-${local.environment}"
  public_key = file(var.public_key_path)
}

