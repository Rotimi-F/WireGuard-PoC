# Create VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_support = true
}

# Create public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone = "eu-west-1a" 
}

# Create private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_block
  map_public_ip_on_launch = false
  availability_zone = "eu-west-1b"
}

# Create internet gateway and attach it to VPC
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Grant the VPC internet access on its main route table
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.main.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# Create security group for WireGuard server
resource "aws_security_group" "wireguard_server_sg" {
  vpc_id = aws_vpc.main.id

  // Add appropriate ingress rules for WireGuard server
  ingress {
    from_port   = 51820
    to_port     = 51820
    protocol    = "UDP"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Add appropriate egress rules for WireGuard server
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create WireGuard server instance in the public subnet
resource "aws_instance" "wireguard_server" {
  ami           = "ami-0d940f23d527c3ab1" # Specify a suitable AMI
  instance_type = "t2.micro"      # Adjust instance type as needed
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.wireguard_server_sg.id]
  key_name = "mykeypair"
  user_data = <<-EOF
              #!/bin/bash
              sudo add-apt-repository -y ppa:wireguard/wireguard
              sudo apt update
              sudo apt install -y wireguard-go
              sudo apt-get install wireguard-tools
              sudo mkdir -p /etc/wireguard
              sudo wg genkey | sudo tee etc/wireguard/privatekey | sudo wg pubkey | sudo tee /etc/wireguard/publickey
              sudo tee /etc/wireguard/wg0systemctl.conf <<EOF1
              [Interface]
              Address = 10.0.1.10/24  # Adjust IP address and subnet mask as needed
              ListenPort = 51820       # Adjust the port if needed
              PrivateKey = $(sudo cat /etc/wireguard/privatekey)
              SaveConfig = true

              #Add peers below
              [Peer]
              PublicKey = "client_public_key_here"
              AllowedIPs = 10.0.3.0/24
              Endpoint = "client_public_ip_here:51820"
              
              EOF1
              sudo wg-quick up wg0
              sudo systemctl enable wg-quick@wg0systemctl.service
              sudo systemctl start wg-quick@wg0systemctl.service
              # Configure WireGuard here
              EOF

  // Additional configuration for WireGuard server instance
  // (Install WireGuard, configure interfaces, IP addresses, routing)
}

# Create security group for HTTP server
resource "aws_security_group" "http_server_sg" {
  vpc_id = aws_vpc.main.id

  // Add appropriate ingress rules for HTTP server
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Add appropriate egress rules for HTTP server
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create HTTP server instance in the private subnet
resource "aws_instance" "http_server" {
  ami           = "ami-0d940f23d527c3ab1" # Specify a suitable AMI with HTTP server software installed
  instance_type = "t2.micro"      # Adjust instance type as needed
  subnet_id     = aws_subnet.private.id
  security_groups = [aws_security_group.http_server_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt install -y apache2
              sudo systemctl start apache2
              EOF
  

  // Additional configuration for HTTP server instance
  // (Install and configure HTTP server software)
}
