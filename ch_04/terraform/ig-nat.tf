resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.backup_test_vpc.id
  tags = {
    Name = "backup_test_IGW"
  }
}
output "igw_id" {
  value = aws_internet_gateway.public_igw.id
}