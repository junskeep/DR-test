data "aws_availability_zones" "available" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}


resource "aws_subnet" "backup_test_vpc_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.backup_test_vpc.id
  cidr_block              = slice(["172.3.1.0/24", "172.3.2.0/24"], count.index, count.index + 1)[0]
  availability_zone       = slice(data.aws_availability_zones.available.names, count.index, count.index + 1)[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "backup_test_vpc-subnet-${count.index}"
  }
}