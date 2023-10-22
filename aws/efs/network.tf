resource "aws_vpc" "example-efs-vpc" {
  cidr_block = "192.168.0.0/16"
  tags = {
    Name = "example-efs-vpc"
  }
}

resource "aws_subnet" "example-efs-subnet" {
  vpc_id     = aws_vpc.example-efs-vpc.id
  cidr_block = "192.168.1.0/24"
  availability_zone = "eu-central-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "example-efs-vpc-subnet"
  }
}

resource "aws_internet_gateway" "example-efs-igw" {
  vpc_id = aws_vpc.example-efs-vpc.id
  tags = {
    Name = "example-efs-igw"
  }
} 

resource "aws_route_table" "example-efs-rt" {
  vpc_id = aws_vpc.example-efs-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example-efs-igw.id
  }
} 

resource "aws_route_table_association" "example-efs-rt-assoc" {
  subnet_id = aws_subnet.example-efs-subnet.id
  route_table_id = aws_route_table.example-efs-rt.id
} 

resource "aws_security_group" "example-efs-sg" {
  name = "example-efs-sg"
  description = "Traffic allowed in/out of example-efs-instance"
  vpc_id = aws_vpc.example-efs-vpc.id
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
    Name = "example-efs-sg"
  }
}