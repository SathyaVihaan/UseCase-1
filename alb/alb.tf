resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.az1.id, aws_subnet.az2.id, aws_subnet.az3.id]
}

resource "aws_lb_target_group" "homepage_tg" {
  name     = "homepage-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "register_tg" {
  name     = "register-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group" "image_tg" {
  name     = "image-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_target_group_attachment" "homepage_attach" {
  target_group_arn = aws_lb_target_group.homepage_tg.arn
  target_id        = aws_instance.homepage.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "register_attach" {
  target_group_arn = aws_lb_target_group.register_tg.arn
  target_id        = aws_instance.register.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "image_attach" {
  target_group_arn = aws_lb_target_group.image_tg.arn
  target_id        = aws_instance.image.id
  port             = 80
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.homepage_tg.arn
  }
}

resource "aws_lb_listener_rule" "register_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.register_tg.arn
  }

  condition {
    path_pattern {
      values = ["/register"]
    }
  }
}

resource "aws_lb_listener_rule" "image_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.image_tg.arn
  }

  condition {
    path_pattern {
      values = ["/image"]
    }
  }
}
