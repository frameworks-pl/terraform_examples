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

