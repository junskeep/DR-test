resource "aws_security_group" "test-db-sg" {
  name        = "test-db-sg"
  description = "Security group for database"
  vpc_id      = aws_vpc.backup_test_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backup_test_SG"
  }
}
