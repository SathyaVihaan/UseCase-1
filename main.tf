provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "homepage" {
  ami           = "ami-0953476d60561c955" # Replace with valid AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.az1.id
  user_data     = <<-EOF
                #!/bin/bash
                echo "Homepage" > /var/www/html/index.html
                nohup busybox httpd -f -p 80 &
                EOF
  instance" "register" {
  ami           = "ami-0953476d60561c955"
  instance_type = "t2.micro"
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
  ami           = "ami-0953476d60561c955"
  instance_type = "t2.micro"
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

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "az1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "az2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "az3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1c"
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
