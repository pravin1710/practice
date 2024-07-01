resource "aws_alb" "application_load_balancer" { //load balancer configuration
  name                       = "${var.app_name}-${var.app_environment}-alb"
  internal                   = false
  load_balancer_type         = "application"
  subnets                    = aws_subnet.public.*.id
  security_groups            = [aws_security_group.load_balancer_security_group.id]
  idle_timeout               = "60"
  enable_deletion_protection = "false"
  enable_http2               = "true"

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.app_environment
  }
}

resource "aws_security_group" "load_balancer_security_group" { //security group for load balancer
  vpc_id = aws_vpc.aws-vpc.id


  ingress { // Inbound rules which allows request from port 80 to target group
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/16"]
    ipv6_cidr_blocks = []
    self             = false
  }

  egress { // Outbound rules which allows traffic out from vpc to anywhere
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  ingress { // Inbound rules which allows request from port 443 to target group
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    self             = false
  }

  egress { // Outbound rules which allows traffic out from vpc to anywhere
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }

  ingress { // Inbound rules which allows request from port 8080 to target group
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
    self             = false
  }

  egress { // Outbound rules which allows traffic out from vpc to anywhere
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  ingress { // Inbound rules which allows request from port 80 to target group
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/16"]
    ipv6_cidr_blocks = []
    self             = false
  }

  egress { // Outbound rules which allows traffic out from vpc to anywhere
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }



  tags = {
    Name        = "${var.app_name}-sg"
    Environment = var.app_environment
  }


}

resource "aws_lb_target_group" "calander_service_fargates" { //load balancer target group calendar-service
  name                 = "${var.service-2}-tg"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = aws_vpc.aws-vpc.id
  target_type          = "ip"
  deregistration_delay = "300"
  slow_start           = 0

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    matcher             = "200-299"
    path                = "/calendar-service/meta/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
  stickiness {
    cookie_duration = 86400
    enabled         = false
    type            = "lb_cookie"
  }

  tags = {
    Name        = "${var.app_name}-${var.service-2}-lb-tg"
    Environment = var.app_environment
  }
}

resource "aws_lb_listener" "listener_http" { //listining on port 80 
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.calander_service_fargates.arn
        weight = 1
      }

      stickiness {
        enabled  = true
        duration = 28800
      }
    }
  }
}

# resource "aws_lb_listener" "listener_https" { //listining on port 443
#   load_balancer_arn = aws_alb.application_load_balancer.id
#   port              = "443"
#   protocol          = "HTTPS"
#   certificate_arn   = var.certificate_arn
#   ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"

#   default_action {
#     type = "forward"
#     forward {
#       target_group {
#         arn    = aws_lb_target_group.calander_service_fargates.arn
#         weight = 1
#       }

#       stickiness {
#         enabled  = true
#         duration = 28800
#       }
#     }
#   }
# }

resource "aws_lb_listener_rule" "calendar-service-listener" { //listener rule to forward request on calendar service
  listener_arn = aws_lb_listener.listener_http.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.calander_service_fargates.arn
  }
  condition {
    host_header {
      values = ["${var.aws_region}.${var.service-1}"]
    }
  }
}
