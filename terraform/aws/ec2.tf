resource "aws_instance" "web_host" {
  # ec2 have plain text secrets in user data
  ami           = var.ami
  instance_type = "t2.nano"

  vpc_security_group_ids = [
  "${aws_security_group.web-node.id}"]
  subnet_id = aws_subnet.web_subnet.id
  user_data = <<EOF
#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2
export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMAAA
export AWS_SECRET_ACCESS_KEY=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
export AWS_DEFAULT_REGION=us-west-2
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
EOF
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web_host"
    yor_trace   = "32943d64-f5ad-4336-8993-0bf3089f5002"
  }
}

resource "aws_ebs_volume" "web_host_storage" {
  # unencrypted volume
  availability_zone = "${var.region}a"
  #encrypted         = false  # Setting this causes the volume to be recreated on apply 
  size = 1
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web_host_storage"
    yor_trace   = "874246b5-e959-4c4b-9a25-555219eee1b0"
  }
}

resource "aws_ebs_snapshot" "example_snapshot" {
  # ebs snapshot without encryption
  volume_id   = aws_ebs_volume.web_host_storage.id
  description = "${local.resource_prefix.value}-ebs-snapshot"
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "example_snapshot"
    yor_trace   = "61357901-2ffe-47a8-a548-47b9d37db54c"
  }
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.web_host_storage.id
  instance_id = aws_instance.web_host.id
}

resource "aws_security_group" "web-node" {
  # security group is open to the world in SSH port
  name        = "${local.resource_prefix.value}-sg"
  description = "${local.resource_prefix.value} Security Group"
  vpc_id      = aws_vpc.web_vpc.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
    "0.0.0.0/0"]
  }
  depends_on = [aws_vpc.web_vpc]
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web-node"
    yor_trace   = "38b9f302-2993-4ce8-8422-38ac9ce7a1d9"
  }
}

resource "aws_vpc" "web_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web_vpc"
    yor_trace   = "a8a597fe-18ac-4c51-aba6-0b7bc0e3cbd6"
  }
}

resource "aws_subnet" "web_subnet" {
  vpc_id                  = aws_vpc.web_vpc.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web_subnet"
    yor_trace   = "3967cb35-e452-4f73-b3c9-49f60a7a9eb2"
  }
}

resource "aws_subnet" "web_subnet2" {
  vpc_id                  = aws_vpc.web_vpc.id
  cidr_block              = "172.16.11.0/24"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web_subnet2"
    yor_trace   = "ff6bdf0d-c0ae-4b23-a676-c5d0e55bf6a7"
  }
}


resource "aws_internet_gateway" "web_igw" {
  vpc_id = aws_vpc.web_vpc.id
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web_igw"
    yor_trace   = "1b4fb2d7-0595-4a83-b407-a20704540dc4"
  }
}

resource "aws_route_table" "web_rtb" {
  vpc_id = aws_vpc.web_vpc.id
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web_rtb"
    yor_trace   = "45c0fd52-21b8-4cbf-9763-d659b9bd14d9"
  }
}

resource "aws_route_table_association" "rtbassoc" {
  subnet_id      = aws_subnet.web_subnet.id
  route_table_id = aws_route_table.web_rtb.id
}

resource "aws_route_table_association" "rtbassoc2" {
  subnet_id      = aws_subnet.web_subnet2.id
  route_table_id = aws_route_table.web_rtb.id
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.web_rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.web_igw.id
  timeouts {
    create = "5m"
  }
}


resource "aws_network_interface" "web-eni" {
  subnet_id   = aws_subnet.web_subnet.id
  private_ips = ["172.16.10.100"]
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "web-eni"
    yor_trace   = "ef2f6055-27df-4a21-8288-e98f1319bd6f"
  }
}

# VPC Flow Logs to S3
resource "aws_flow_log" "vpcflowlogs" {
  log_destination      = aws_s3_bucket.flowbucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.web_vpc.id
  tags = {
    env       = "dev"
    yor_name  = "vpcflowlogs"
    yor_trace = "15235b34-126f-438b-9470-1d3943e8426b"
  }
}

resource "aws_s3_bucket" "flowbucket" {
  bucket        = "${local.resource_prefix.value}-flowlogs"
  force_destroy = true
  tags = {
    env         = "dev"
    cost-center = "44010"
    yor_name    = "flowbucket"
    yor_trace   = "ac63efb9-a8d3-4cc2-8b87-573400d350f7"
  }
}

output "ec2_public_dns" {
  description = "Web Host Public DNS name"
  value       = aws_instance.web_host.public_dns
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.web_vpc.id
}

output "public_subnet" {
  description = "The ID of the Public subnet"
  value       = aws_subnet.web_subnet.id
}

output "public_subnet2" {
  description = "The ID of the Public subnet"
  value       = aws_subnet.web_subnet2.id
}
