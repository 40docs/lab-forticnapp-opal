# Infrastructure that passes most standard IaC checks
# BUT still violates critical business requirements

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

# Production web server - PASSES most standard checks ✅
resource "aws_instance" "production_web" {
  ami           = "ami-12345678"
  instance_type = "t3.medium"

  # Has security groups ✅ (standard scanners happy)
  # BUT missing required audit-logging-sg ❌ (business requirement)
  vpc_security_group_ids = [
    aws_security_group.web_sg.id
  ]

  # Encryption enabled ✅
  root_block_device {
    encrypted = true
    volume_type = "gp3"
  }

  # Monitoring enabled ✅
  monitoring = true

  # Metadata options configured ✅
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"  # IMDSv2 enforced ✅
  }

  # Proper tagging ✅
  tags = {
    Name        = "prod-web-01"
    Environment = "production"  # Company policy: production REQUIRES audit-logging-sg
    Owner       = "platform-team"
    CostCenter  = "engineering"
    Backup      = "daily"
  }
}

# Well-configured security group - passes standard checks ✅
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Security group for web servers - HTTPS only from internal network" # Has description ✅

  ingress {
    description = "HTTPS from internal network" # Has description ✅
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Not 0.0.0.0/0 ✅
  }

  egress {
    description = "Allow outbound HTTPS for package updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "web-sg"
    Environment = "production"
  }
}

# This security group EXISTS but isn't attached to production instance
# Standard scanners don't check if SPECIFIC security groups are attached
resource "aws_security_group" "audit_logging_sg" {
  name        = "audit-logging-sg"
  description = "REQUIRED for all production instances per company policy - sends logs to SIEM"

  egress {
    description = "Syslog to internal SIEM collector"
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]  # Internal only ✅
  }

  egress {
    description = "Encrypted syslog to SIEM"
    from_port   = 6514
    to_port     = 6514
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = {
    Name       = "audit-logging-sg"
    Required   = "production"
    Compliance = "SOC2-mandatory"
  }
}

# S3 bucket for logs - well configured ✅
resource "aws_s3_bucket" "logs" {
  bucket = "my-secure-logs-bucket-demo-2024"

  tags = {
    Name        = "logs-bucket"
    Environment = "production"
  }
}

# S3 bucket encryption ✅
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket versioning ✅
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 bucket public access block ✅
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}