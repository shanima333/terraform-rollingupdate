################################################################
# Provider Configuration
################################################################

provider "aws"  {
  region     = "us-east-2"
  access_key = "AKIA6NZZHG62M6QY3G74"
  secret_key = "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"
}


################################################################
# VPC creation
################################################################

resource "aws_vpc" "blog" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "blog"
  }
}


################################################################
#public subnet - 1  creation
################################################################

resource "aws_subnet" "blog-public1" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "10.0.0.0/19"
  availability_zone = "us-east-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "blog-public1"
  }
}

################################################################
#public subnet - 2  creation
################################################################

resource "aws_subnet" "blog-public2" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "10.0.32.0/19"
  availability_zone = "us-east-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "blog-public2"
  }
}

################################################################
#public subnet - 3  creation
################################################################

resource "aws_subnet" "blog-public3" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "10.0.64.0/19"
  availability_zone = "us-east-2c"
  map_public_ip_on_launch = true

  tags = {
    Name = "blog-public3"
  }
}



################################################################
#private subnet - 1  creation
################################################################

resource "aws_subnet" "blog-private1" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "10.0.96.0/19"
  availability_zone = "us-east-2a"
  tags = {
    Name = "blog-private1"
  }
}

################################################################
#private subnet - 2  creation
################################################################


resource "aws_subnet" "blog-private2" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "10.0.128.0/19"
  availability_zone = "us-east-2b"
  tags = {
    Name = "blog-private2"
  }
}

################################################################
#private subnet - 2  creation
################################################################


resource "aws_subnet" "blog-private3" {
  vpc_id     = aws_vpc.blog.id
  cidr_block = "10.0.160.0/19"
  availability_zone = "us-east-2c"
  tags = {
    Name = "blog-private3"
  }
}


################################################################
#internet gateway  creation
################################################################


resource "aws_internet_gateway" "blog-igw" {
  vpc_id = aws_vpc.blog.id

  tags = {
    Name = "blog-igw"
  }
}

################################################################
#public route table  creation
################################################################

resource "aws_route_table" "blog-public-RT" {
  vpc_id = aws_vpc.blog.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.blog-igw.id
        }
   tags = {
        Name ="blog-public-RT"
        }
}


################################################################
#public route table  association
################################################################

resource "aws_route_table_association" "blog-public-RT" {
  subnet_id      = aws_subnet.blog-public1.id
  route_table_id = aws_route_table.blog-public-RT.id
}

################################################################
#public subnet 2 and  route table  association
################################################################

resource "aws_route_table_association" "blog-public2-RT" {
  subnet_id      = aws_subnet.blog-public2.id
  route_table_id = aws_route_table.blog-public-RT.id
}

################################################################
#public subnet 2 and  route table  association
################################################################

resource "aws_route_table_association" "blog-public3-RT" {
  subnet_id      = aws_subnet.blog-public3.id
  route_table_id = aws_route_table.blog-public-RT.id
}


################################################################
#eip creation
################################################################

resource "aws_eip" "nat" {
  vpc      = true
  tags = {
    Name = "blog-eip"
  }
}

################################################################
#nat gateway creation
################################################################


resource "aws_nat_gateway" "blog-nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.blog-public2.id

  tags = {
    Name = "blog-NAT"
  }
}

################################################################
#private route table  creation
################################################################

resource "aws_route_table" "blog-private-RT" {
  vpc_id = aws_vpc.blog.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.blog-nat.id
  }

  tags = {
    Name = "blog-private-RT"
         }
}


################################################################
#private subnet 1 to route table  association
################################################################

resource "aws_route_table_association" "blog-private1-RT" {
  subnet_id      = aws_subnet.blog-private1.id
  route_table_id = aws_route_table.blog-private-RT.id
}


################################################################
#private subnet 2 to route table  association
################################################################

resource "aws_route_table_association" "blog-private2-RT2" {
  subnet_id      = aws_subnet.blog-private2.id
  route_table_id = aws_route_table.blog-private-RT.id
}

################################################################
#private subnet 3 to route table  association
################################################################

resource "aws_route_table_association" "blog-private3-RT2" {
  subnet_id      = aws_subnet.blog-private3.id
  route_table_id = aws_route_table.blog-private-RT.id
}

################################################################
#keypair
################################################################

resource "aws_key_pair" "ohio-webserver" {
  key_name   = "ohio-webserver"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKoQnz+jeMN7sQRgN4VWDbAcaZ3KqnqDeBN53RDqGJXY5qFbOZ2BoTUUHNXmV2hDo/b6I+pSS/W/QUPPw6h8IPnIgByijbJFvPxpaSRLmKrw1Ut0xr8/sN2lAXhX9clCzEgAQdhzE8TbMyQhlnixxe/dRPQX6MHZhQCsWlAuzt45+6JdMpq0Qk6GScngPTRWyR1bY9DXshFa3oudtUOtpkvObdd0rUX9q9z09jPFPc6GFVPNnJDOuWymAppX2s7cAeMTyRCYcBClWhOmw8w+BYmoTfrkxXbux5L+xXZ2gv6zQykx3RkFiLmHf41tP/LVbhQ5pIk056jomHTkf1pMKH root@ip-172-31-38-199.us-east-2.compute.internal"
}

################################################################
#security group for clb
################################################################

resource "aws_security_group" "lb-tesing" {
  name        = "lb-testing"
  description = "Allow from all"
  vpc_id      = aws_vpc.blog.id


ingress {
    description = "allow from all"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb-testing"
  }
}

##################################################################
# Launch Configuration
##################################################################

resource "aws_launch_configuration" "lb-testing" {
 
  image_id = "ami-09558250a3419e7d0"
  instance_type = "t2.micro"
  key_name = aws_key_pair.ohio-webserver.id
  security_groups = [ aws_security_group.lb-tesing.id ]
  user_data = file("setup.sh")
    
  lifecycle {
    create_before_destroy = true
  }
      
}

##################################################################
# Load balancer
##################################################################

	
resource "aws_elb" "lb-testing" {
  name               = "lb-testing"
  security_groups = [aws_security_group.lb-tesing.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

 subnets = [aws_subnet.blog-public1.id, aws_subnet.blog-public2.id, aws_subnet.blog-public3.id]

  cross_zone_load_balancing   = true
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:8000/index.php"
    interval            = 15
  }
   tags = {
    Name = "lb-testing"
  }
}

##################################################################
# Autoscaling
##################################################################


resource "aws_autoscaling_group" "lb-testing-ASG" {
  name                 = "lb-testing-ASG"
  launch_configuration = aws_launch_configuration.lb-testing.name
  min_size             = 2
  desired_capacity      = 2
  max_size             = 3
  health_check_grace_period = 120
  health_check_type         = "EC2"
  load_balancers	= [aws_elb.lb-testing.id]
  vpc_zone_identifier =[aws_subnet.blog-public1.id, aws_subnet.blog-public2.id, aws_subnet.blog-public3.id]
  tag {
    key = "Name"
    propagate_at_launch = true
    value = "webserver"
  }
  lifecycle {
    create_before_destroy = true
  }
}

