resource "aws_vpc" "backup_test_vpc" {
  cidr_block           = "172.3.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "backup_test_vpc"
  }
}
output "vpc_share" {
  value = aws_vpc.backup_test_vpc.id
}

output "vpc_cidr_share" {
  value = aws_vpc.backup_test_vpc.cidr_block
}
