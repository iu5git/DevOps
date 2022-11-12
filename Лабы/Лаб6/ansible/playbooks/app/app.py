import os
from dotenv import load_dotenv

from typing import List, Dict
from flask import Flask
import mysql.connector
import json
import socket

dotenv_path = os.path.join(os.path.dirname(__file__), '.env')
if os.path.exists(dotenv_path):
    load_dotenv(dotenv_path)
app = Flask(__name__)


def test() -> List[Dict]:
    config = {
        'user': os.environ.get('MYSQL_USER'),
        'password': os.environ.get('MYSQL_PASSWORD'),
        'host': os.environ.get('MYSQL_HOST'),
        'port': os.environ.get('MYSQL_PORT'),
        'database': 'testdb'
    }
    connection = mysql.connector.connect(**config)
    cursor = connection.cursor()
    cursor.execute('SELECT * FROM test')
    row_headers=[x[0] for x in cursor.description] #this will extract row headers
    rv = cursor.fetchall()
    json_data=[]
    for result in rv:
        json_data.append(dict(zip(row_headers,result)))
    cursor.close()
    connection.close()

    return json.dumps({socket.gethostname(): json_data})


@app.route('/')
def index() -> str:
    return test()


if __name__ == '__main__':
    app.run(host='0.0.0.0')
