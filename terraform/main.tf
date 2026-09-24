# Aws security group to allow SSH access

resource "aws_security_group" "flo_allow_ssh" {
  name        = "flo_allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  egress {
    from_port   = 443 
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80 
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "flo-allow-ssh"

  }
}

### Create a key pair for SSH access
# Generate a secure private key using RSA algorithm
resource "tls_private_key" "rsa_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create an AWS Key Pair using the public key from the step above
resource "aws_key_pair" "flo_key" {
  key_name   = "flo_key"
  public_key = tls_private_key.rsa_key.public_key_openssh
}

# 3. Save the private key locally to a file so you can use it to SSH
resource "local_file" "private_key_file" {
  content  = tls_private_key.rsa_key.private_key_pem
  filename = "${path.module}/flo-ec2-ssh-key.pem"
  
  # Sets the correct file permissions (read-only for owner) required by SSH clients
  file_permission = "0400" 
}


#aws_instance resource to create a virtual machine
resource "aws_instance" "flo-machine" {
  ami           = "ami-0b6d9d3d33ba97d99"
  instance_type = "t2.micro"
  key_name = aws_key_pair.flo_key.key_name
  tags = {
    Name = "flo-machine"
  }
  vpc_security_group_ids = [aws_security_group.flo_allow_ssh.id]

  user_data = file("${path.module}/startup.sh")
}
