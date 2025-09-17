# This SHOULD pass - production instance with audit logging
resource "aws_instance" "good_production" {
  ami           = "ami-12345"
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.web_sg.id,
    aws_security_group.audit_logging_sg.id  # Required for production
  ]

  tags = {
    Name        = "prod-web-01"
    Environment = "production"
  }
}

# This SHOULD pass - development instance without audit logging
resource "aws_instance" "good_development" {
  ami           = "ami-12345"
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.dev_sg.id  # No audit required for dev
  ]

  tags = {
    Name        = "dev-web-01"
    Environment = "development"
  }
}

# Supporting security groups
resource "aws_security_group" "web_sg" {
  name = "web-sg"
}

resource "aws_security_group" "audit_logging_sg" {
  name = "audit-logging-sg"
}

resource "aws_security_group" "dev_sg" {
  name = "dev-sg"
}