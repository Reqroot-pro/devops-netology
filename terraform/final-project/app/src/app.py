from flask import Flask
import os
import mysql.connector

app = Flask(__name__)

@app.route('/')
def hello():
    try:
        conn = mysql.connector.connect(
            host=os.getenv('DB_HOST'),
            user=os.getenv('DB_USER'),
            password=os.getenv('DB_PASSWORD'),
            database=os.getenv('DB_NAME')
        )
        status = "DB connected"
        conn.close()
    except Exception as e:
        status = f"DB error: {str(e)}"

    return f"Hello from Flask! {status}"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)