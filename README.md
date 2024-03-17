# WireGuard-PoC
**WireGuard VPN Setup in AWS with Terraform**
This project demonstrates how to set up a WireGuard VPN server in an AWS environment using Terraform. The VPN server allows engineers to securely access services deployed in a private subnet from their laptops.

**Prerequisites**
Before getting started, ensure you have the following prerequisites:
•	An AWS account with appropriate permissions to create resources.
•	Terraform installed on your local machine. You can download it from here https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli. 
•	WireGuard installed on the engineer's laptop. Follow the installation instructions for your operating system here https://www.wireguard.com/install/.

**Created Resources**
•	EC2 instance for WireGuard server, that is automatically configured with user-data.
•	Server running http service (apache)
•	WireGuard client (Engineer’s laptop)

**Setup Instructions**
Follow the steps below to set up the WireGuard VPN solution:
Part 1: AWS Infrastructure Setup with Terraform
Clone this repository to your local machine:
'''
1) Git clone <repository-url>

2) Navigate to the project directory:
'''
cd wireguard-aws-terraform

4) Open the variables.tf file and customize the Terraform variables according to your requirements. You can specify the AWS region, VPC CIDR block, and other parameters.

5) Initialize Terraform:
   '''
   terraform init
   
6) Provision the AWS Infrastructure
   '''
   terraform apply
Note down the public IP address of the WireGuard server instance provisioned in AWS. You'll need this to configure WireGuard on the engineer's laptop.

Part 2: Engineer's Laptop Configuration
Install Wireguard on the Client either from

