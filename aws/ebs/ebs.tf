provider "aws" {
    region = "eu-central-1"
    #access_key comes from env variable AWS_ACCESS_KEY
    #secret_key comes from env varaible AWS_SECRET_KEY
}

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


# resource "aws_network_interface" "example-ebs-nic" {
#   subnet_id = aws_subnet.example-ebs-subnet.id
#   security_groups = [aws_security_group.example-ebs-sg.id]
#   tags = {
#     Name = "example-ebs-proxy-nic"
#   }  
# }

resource "aws_ebs_volume" "example-ebs-volume" {
    availability_zone = "eu-central-1a"
    size = 1
    tags = {
        Name = "ebs-example"
    }
}


resource "aws_instance" "example-ebs-instance" {
  ami           = "ami-0ab1a82de7ca5889c"
  instance_type = "t3.micro"
  availability_zone = "eu-central-1a"
  key_name = "aws_tests"
  subnet_id = aws_subnet.example-ebs-subnet.id
  security_groups = [aws_security_group.example-ebs-sg.id]
  
#   network_interface {
#     device_index = 0
#     network_interface_id = aws_network_interface.example-ebs-nic.id
#   }

  tags = {
    Name = "ebs-example"
  }
}

resource "aws_volume_attachment" "example-ebs-volume-attachement" {

  #Apparently this name will not be created for g2 type EBS, instead a device with name like /dev/nvme1n1 will be created
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.example-ebs-volume.id
  instance_id = aws_instance.example-ebs-instance.id

  #IMPORTANT: 1. If this is new EBS, it will have to be formatted manually (sudo mkfs -t ext4 /dev/nvme1n1) 
  #           2. It will have to be mounted manually on instance:
  #              sudo mkdir /mnt/example-ebs-volume
  #              sudo mount /dev/nvme1n1 /mnt/example-ebs-volume
}

