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
1. **Clone this repository to your local machine**:
```
Git clone <repository-url>
```
2. **Navigate to the project directory**:
```
cd wireguard-aws-terraform
```
3. **Open the variables.tf file and customize the Terraform variables according to your requirements. You can specify the AWS region, VPC CIDR block, and other parameters**.

4. **Initialize Terraform**:
   ```
   terraform init
   ```
5. **Provision the AWS Infrastructure**
   ```
   terraform apply
   ```
Note down the public IP address of the WireGuard server instance provisioned in AWS. You'll need this to configure WireGuard on the engineer's laptop.

Part 2: Engineer's Laptop Configuration

To configure WireGuard on the engineer's laptop, you will need to install WireGuard. The installation steps vary based on the operating system. Below is a general guide:

1. **Install WireGuard**:
   - **Windows/Mac**: Download and install from [WireGuard's official site](https://www.wireguard.com/install/).
   - **Linux**: Install WireGuard using your distribution's package manager, for example,
     ```
     sudo apt install wireguard
     ```.

2. **Configure WireGuard Client**:
   - Generate client keys:
     ```
     wg genkey | tee privatekey | wg pubkey > publickey
     ```
   - Create a `wg0-client.conf`
   ```
   nano wg0-client.conf
   ```
   - Input in the file  the following content, replacing placeholders with actual values:
     ```
     [Interface]
     PrivateKey = <client-private-key>
     Address = 10.0.3.2/24
     
     [Peer]
     PublicKey = <server-public-key>
     Endpoint = <server-public-ip>:51820
     AllowedIPs = 10.0.0.0/16
     PersistentKeepalive = 25
     ```
   - The `AllowedIPs = 10.0.0.0/16` line directs all traffic for the VPC through the VPN. Adjust this as necessary for your network configuration.

3. **Start WireGuard**:
   - Activate the configuration: `wg-quick up wg0-client.conf` (you might need to specify the full path to the config file).
     ```
     sudo wg-quick up wg0
     ```
4. **Verify WireGuard Tunnel**
   ```
   sudo wg show
   ```
5. **Test the connection to ensure you can reach your services in the private subnet**:
   ```
   curl http://<private-ip-of-http-service>
   ```

Cleanup
After you're done testing, don't forget to clean up the resources to avoid incurring unnecessary costs.

Destroy the AWS infrastructure:
```
terraform destroy
```

Conclusion
You have successfully set up a WireGuard VPN server in AWS using Terraform and configured it on the engineer's laptop to securely access http services deployed in a private subnet. Feel free to explore further customization options and integrations as per your requirements.
Remember, for real-world use, securely transfer the public keys between the server and clients, and manage configurations with care, especially regarding key handling and IP assignments. This setup is a basic example and might need adjustments based on specific requirements or constraints of your environment.


