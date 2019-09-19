resource "aws_route53_zone" "internal" {
  name = "automi.local"

  vpc {
    vpc_id = "${aws_vpc.vpc.id}"
  }
}
