resource "aws_instance" "homepage" {
  ami           = "ami-0c55b159cbfafe1f0" # Replace with valid AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.az1.id
  user_data     = <<-EOF
                #!/bin/bash
                echo "Homepage" > /var/www/html/index.html
                nohup busybox httpd -f -p 80 &
                EOF
 _instance" "register" {
  ami           = "ami-0c55b159cbfafe1f0"
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
  ami           = "ami-0c55b159cbfafe1f0"
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
