resource "aws_lb" "application" {
  name               = "${local.environment}-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = ["${aws_security_group.web.id}", "${aws_security_group.internet_access.id}"]
  subnets            = ["${aws_subnet.subnet.id}", "${aws_subnet.backup.id}"]

  #enable_deletion_protection = true

  #access_logs {
  #  bucket  = "${aws_s3_bucket.lb_logs.bucket}"
  #  prefix  = "test-lb"
  #  enabled = true
  #}

  tags = {
    Name = "${local.environment}: load balancer"
  }
}

resource "aws_lb_listener" "redirect_80_443" {
  load_balancer_arn = "${aws_lb.application.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "application" {
  load_balancer_arn = "${aws_lb.application.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:ap-south-1:334239633320:certificate/ded2dd5f-83af-423b-963f-c571d1075a45"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.portal.arn}"
  }
}

resource "aws_lb_target_group" "portal" {
  name        = "${local.environment}-portal"
  port        = 8010
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "portal" {
  target_group_arn = "${aws_lb_target_group.portal.arn}"
  target_id        = "${aws_instance.app_server.id}"
  port             = 8010
}

resource "aws_lb_target_group" "webhook" {
  name        = "${local.environment}-webhook"
  port        = 8015
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "webhook" {
  target_group_arn = "${aws_lb_target_group.webhook.arn}"
  target_id        = "${aws_instance.app_server.id}"
  port             = 8015
}

resource "aws_lb_listener_rule" "webhook" {
  listener_arn = "${aws_lb_listener.application.arn}"

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.webhook.arn}"
  }

  condition {
    field  = "path-pattern"
    values = ["/v1.0/webhook/api/*"]
  }
}

# public DNS name for the LB (e.g. the main application)
resource "aws_route53_record" "application" {
  zone_id = var.route53_zone_id
  name    = "${local.environment == "production" ? "app" : local.environment}"
  type    = "CNAME"
  ttl     = "60"
  records = ["${aws_lb.application.dns_name}"]
}
