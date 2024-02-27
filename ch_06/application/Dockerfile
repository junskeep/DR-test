# 사용할 기본 이미지
FROM python:3.11-alpine3.18 as builder

# 작업할 디렉토리 설정
WORKDIR /app

# 필요한 파일들을 Docker 이미지 안으로 복사
COPY ./app.py /app/app.py
COPY ./DatabaseConfig.py /app/DatabaseConfig.py
COPY ./static/index.html /app/static/index.html

# Python 라이브러리 설치(필요한 라이브러리가 있다면 requirements.txt로 관리하시는 걸 추천드립니다.)
RUN pip install flask flask_sqlalchemy pymysql

# 환경 변수 설정 (환경 변수는 쿠버네티스에서 파드에 띄울 때 세팅 가능)
ENV DB_USERNAME=admin
ENV DB_PASSWORD=awsbackup134
ENV DB_HOST=test-db.cchr31xzxtrq.ap-northeast-1.rds.amazonaws.com
ENV DB_PORT=3306
ENV DB_SCHEMA=sys

# 컨테이너가 실행될 때 어떤 명령을 실행할 지 결정
CMD [ "python3", "./app.py" ]