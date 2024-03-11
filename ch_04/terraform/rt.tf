resource "aws_route_table" "backup_test_rt" {
  vpc_id = aws_vpc.backup_test_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }
}
resource "aws_route_table_association" "backup_test_rt" {
  route_table_id = aws_route_table.backup_test_rt.id
  count          = length(aws_subnet.backup_test_vpc_subnet[*])
  subnet_id      = aws_subnet.backup_test_vpc_subnet[count.index].id
}