# This SHOULD fail - production instance WITHOUT audit logging
resource "aws_instance" "bad_production" {
  ami           = "ami-12345"
  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.web_sg.id
    # MISSING: aws_security_group.audit_logging_sg.id
  ]

  tags = {
    Name        = "prod-web-02"
    Environment = "production"  # Production requires audit logging!
  }
}

# Supporting security group
resource "aws_security_group" "web_sg" {
  name = "web-sg"
}