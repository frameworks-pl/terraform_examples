resource "aws_efs_file_system" "example-efs" {
  creation_token = "example-efs"

  tags = {
    Name = "example-efs"
  }
}

resource "aws_efs_mount_target" "example-efs-mount-target" {
  file_system_id = aws_efs_file_system.example-efs.id
  subnet_id      = aws_subnet.example-efs-subnet.id
  security_groups = [aws_security_group.example-efs-sg.id]
}


variable "AWS_TESTS_KEY_PATH" {
    type = string
}

resource "aws_instance" "example-efs-instance" {
  ami           = "ami-0ab1a82de7ca5889c"
  instance_type = "t3.micro"
  availability_zone = "eu-central-1a"
  key_name = "aws_tests"
  subnet_id = aws_subnet.example-efs-subnet.id
  security_groups = [aws_security_group.example-efs-sg.id]

  tags = {
    Name = "ebs-example"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.AWS_TESTS_KEY_PATH)
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y amazon-efs-utils",
      "sudo mkdir /mnt/efs",
      "sudo mount -t efs ${aws_efs_file_system.example-efs.dns_name}:/ /mnt/efs",
      "sudo chmod go+rw /mnt/efs",
      "sudo mkdir /mnt/efs/test",
      "sudo touch /mnt/efs/test/test.txt",
      "sudo echo 'Hello World' | sudo tee /mnt/efs/test/test.txt",
      "sudo cat /mnt/efs/test/test.txt"
    ]
  }
}