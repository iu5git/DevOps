import os
from typing import List, Dict
from flask import Flask
import mysql.connector
import json

app = Flask(__name__)


def favorite_colors() -> List[Dict]:
    config = {
        'user': os.environ.get('MYSQL_USER'),
        'password': os.environ.get('MYSQL_ROOT_PASSWORD'),
        'host': os.environ.get('MYSQL_HOST'),
        'port': os.environ.get('MYSQL_PORT'),
        'database': 'testdb'
    }
    connection = mysql.connector.connect(**config)
    cursor = connection.cursor()
    cursor.execute('SELECT * FROM test')
    results = [{message} for (message) in cursor]
    cursor.close()
    connection.close()

    return results


@app.route('/')
def index() -> str:
    return json.dumps({'test': favorite_colors()})


if __name__ == '__main__':
    app.run(host='0.0.0.0')
