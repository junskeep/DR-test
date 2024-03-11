resource "aws_db_subnet_group" "backup_test_db" {
  subnet_ids = aws_subnet.backup_test_vpc_subnet[*].id
}

resource "aws_db_instance" "backup_test_db" {
  identifier             = "backup-test-db"
  allocated_storage      = 30
  db_name                = "backup_test_db"
  engine                 = "mysql"
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  db_subnet_group_name   = aws_db_subnet_group.backup_test_db.name
  vpc_security_group_ids = [aws_security_group.test-db-sg.id]
  username               = "testuser"
  password               = var.DB_PASSWORD
  skip_final_snapshot    = true
  publicly_accessible    = true
  delete_automated_backups = false
}

output "db_host" {
  value = aws_db_instance.backup_test_db.address
}
output "db_name" {
  value = aws_db_instance.backup_test_db.db_name
}
output "db_user" {
  value = aws_db_instance.backup_test_db.username
}