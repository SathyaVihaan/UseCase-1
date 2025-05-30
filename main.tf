
provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
}

resource "aws_subnet" "az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_az1
  availability_zone = "${var.region}a"
}

resource "aws_subnet" "az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_az2
  availability_zone = "${var.region}b"
}

resource "aws_subnet" "az3" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_az3
  availability_zone = "${var.region}c"
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "homepage" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.az1.id
  user_data     = <<-EOF
                #!/bin/bash
                echo "Homepage" > /var/www/html/index.html
                nohup busybox httpd -f -p 80 &
                EOF
  tags = {
    Name = "Homepage"
  }
}

resource "aws_instance" "register" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.az2.id
  user_data     = <<-EOF
                #!/bin/bash
                echo "Register Page" > /var/www/html/register.html
                nohup busybox httpd -f -p 80 &
                EOF
  tags = {
    Name = "Register"
  }
}

resource "aws_instance" "image" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.az3.id
  user_data     = <<-EOF
                #!/bin/bash
                echo "Image Page" > /var/www/html/image.html
                nohup busybox httpd -f -p 80 &
                EOF
  tags = {
    Name = "Image"
  }
}

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
