# -*- coding: utf8 -*-

from flask import Flask
from flask import render_template

from api import api

app = Flask(__name__)

app.debug = True

app.register_blueprint(api)

@app.route('/')
def index():
    return render_template('index.html')

if __name__ == '__main__':
    app.run()
