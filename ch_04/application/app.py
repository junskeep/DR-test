from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
import datetime
import DatabaseConfig

app = Flask(__name__)
app.config.from_object(DatabaseConfig)
db = SQLAlchemy(app)

@app.route('/')
def index():
    return app.send_static_file('index.html')

# 클릭 이벤트 모델
class ClickEvent(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    clicked_at = db.Column(db.DateTime, default=datetime.datetime.utcnow)

# 클릭 이벤트 저장
@app.route('/click', methods=['POST'])
def record_click():
    new_click = ClickEvent()
    db.session.add(new_click)
    db.session.commit()
    return jsonify({"message": "Click recorded", "id": new_click.id})

# 클릭 이벤트 조회
@app.route('/clicks', methods=['GET'])
def get_clicks():
    clicks = ClickEvent.query.all()
    return jsonify([{"id": click.id, "clicked_at": click.clicked_at.isoformat()} for click in clicks])

if __name__ == '__main__':
    with app.app_context():
        db.create_all()  # 최초 실행시 테이블 생성
    app.run(debug=True)
