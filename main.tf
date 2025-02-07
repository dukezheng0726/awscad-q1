#vpc
resource "aws_vpc" "q1_VPC" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "q1-VPC"
  }
}

# internet gateway
resource "aws_internet_gateway" "q1_IGW" {
  vpc_id = aws_vpc.q1_VPC.id
  tags = {
    Name = "q1-IGW"
  }
}

# route table
resource "aws_route_table" "q1_PublicRT" {
  vpc_id = aws_vpc.q1_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.q1_IGW.id
  }
  tags = {
    Name = "q1_PublicRT"
  }
}

resource "aws_subnet" "q1_PublicSubnet" {
  vpc_id                  = aws_vpc.q1_VPC.id
  cidr_block              = var.Public_cidr
  availability_zone       = var.az1
  map_public_ip_on_launch = true
  tags = {
    Name = "q1-PublicSubnet"
  }
}

resource "aws_subnet" "q1_PrivateSubnet" {
  vpc_id            = aws_vpc.q1_VPC.id
  cidr_block        = var.Private_cidr
  availability_zone = var.az2
  tags = {
    Name = "q1-PrivateSubnet"
  }
}

resource "aws_route_table_association" "publicsubnet_association" {
  subnet_id      = aws_subnet.q1_PublicSubnet.id
  route_table_id = aws_route_table.q1_PublicRT.id
}


#Security Group - 22/80

resource "aws_security_group" "q1_sg" {
  name        = "q1-sg"
  description = "Allow 22/80 inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.q1_VPC.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


#kms


resource "aws_kms_key" "s3_kms" {
  description              = "KMS Key for S3 Encryption"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  deletion_window_in_days  = 7

  tags = {
    Name = "S3-KMS"
  }
}


#s3
resource "aws_s3_bucket" "exam_logs" {
  bucket = "exam-logs-yan20250206"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "exam_logs_encryption" {
  bucket = aws_s3_bucket.exam_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms.arn 
    }
  }
}



#ec2_ami

resource "aws_instance" "q1_ec2" {
  ami                         = var.ec2_ami
  instance_type               = var.ec2_instance_type
  subnet_id                   = aws_subnet.q1_PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.q1_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "q1-ec2"
  }
}

# dynamodb
resource "aws_dynamodb_table" "q1_table" {
  name     = "q1-table"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity  = 1
  hash_key = "SessionId"

  attribute {
    name = "SessionId"
    type = "S"
  }
}