import os

# AWS RDS 설정 (환경 변수나 구성 파일에서 가져옵니다)
SQLALCHEMY_DATABASE_URI = (
    f"mysql+pymysql://{os.environ.get('DB_USERNAME')}:{os.environ.get('DB_PASSWORD')}@"
    f"{os.environ.get('DB_HOST')}:{os.environ.get('DB_PORT')}/{os.environ.get('DB_SCHEMA')}?charset=utf8"
)
print(SQLALCHEMY_DATABASE_URI)
SQLALCHEMY_TRACK_MODIFICATIONS = False
