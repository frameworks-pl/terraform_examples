resource "aws_vpc" "example-ebs-vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "example-ebs-vpc"
  }
}

resource "aws_subnet" "example-ebs-subnet" {
  vpc_id     = aws_vpc.example-ebs-vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "example-ebs-vpc-subnet"
  }
}

resource "aws_internet_gateway" "example-ebs-igw" {
  vpc_id = aws_vpc.example-ebs-vpc.id
  tags = {
    Name = "example-ebs-igw"
  }
} 

resource "aws_route_table" "example-ebs-rt" {
  vpc_id = aws_vpc.example-ebs-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example-ebs-igw.id
  }
} 

resource "aws_route_table_association" "example-ebs-rt-assoc" {
  subnet_id = aws_subnet.example-ebs-subnet.id
  route_table_id = aws_route_table.example-ebs-rt.id
} 

resource "aws_security_group" "example-ebs-sg" {
  name = "example-ebs-sg"
  description = "Traffic allowed in/out of example-ebs-instance"
  vpc_id = aws_vpc.example-ebs-vpc.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-ebs-sg"
  }
}