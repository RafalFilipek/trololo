# -*- coding: utf8 -*-

from flask import Flask
from flask import render_template

from json import dumps

from api import API

app = Flask(__name__)

app.debug = True

app.register_blueprint(API)

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run()
