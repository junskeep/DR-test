# Bastion EC2 sg
resource "aws_security_group" "backup_test_sg" {
  name   = "backup_test_sg"
  vpc_id = aws_vpc.backup_test_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backup_test-sg"
  }
}
# bastion EIP
resource "aws_eip" "bastion_eip" {
  instance = aws_instance.backup_test_ec2.id
  count    = 1
  tags = {
    Name = "backup_test_eip"
  }
}
# bastion ec2
resource "aws_instance" "backup_test_ec2" {
  ami                    = "ami-0382ac14e5f06eb95"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.backup_test_sg.id]
  subnet_id              = aws_subnet.backup_test_vpc_subnet[0].id
  depends_on             = [aws_db_instance.backup_test_db]
  user_data = <<-EOF
#!/bin/bash
# 우분투 시스템 업데이트 및 필요한 패키지 설치
sudo apt-get update -y
sudo apt-get install -y git python3-pip
# Flask와 Gunicorn 설치
sudo pip3 install flask gunicorn flask_sqlalchemy pymysql

# Flask 애플리케이션을 위한 디렉토리 생성 및 GitHub에서 클론
sudo mkdir -p /var/www/flask_app
cd /var/www/flask_app
sudo git clone https://github.com/junskeep/DR-test.git .
cd ch_04/application/
# Flask 애플리케이션 실행을 위한 환경 변수 설정
DB_USERNAME=${aws_db_instance.backup_test_db.username}
DB_PASSWORD="awsbackup133"
DB_HOST=${aws_db_instance.backup_test_db.address}
DB_PORT=3306
DB_SCHEMA=${aws_db_instance.backup_test_db.db_name}
export FLASK_APP=app.py
export FLASK_ENV=production
export DB_USERNAME DB_PASSWORD DB_HOST DB_PORT DB_SCHEMA
# Gunicorn으로 Flask 애플리케이션 실행
sudo flask run --host=0.0.0.0
EOF

  tags = {
    name = "backup_test_ec2"
  }
}