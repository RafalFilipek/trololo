# -*- coding: utf8 -*-

from flask import Blueprint
from flask import request
from flask import jsonify
from flask import g

import requests

api = Blueprint('api', __name__)

GITLAB_API_URL = 'http://demo.gitlabhq.com/api/v3'

def gitlab_get_api_request(path, **params):
    if g.private_token is False:
        return { 'authorized': False }
    else:
        params['private_token'] = g.private_token
    try:
        r = requests.get('%s/%s/' % (GITLAB_API_URL, path), params=params)
        resp = r.json()
        if 'message' in resp and resp['message'] == '401 Unauthorized':
            return { 'authorized': False }
        else:
            return {
                'authorized': True,
                'data': resp
            }
    except requests.exceptions.RequestException:
        return {
            'error': 'Błąd podczas połączenia z %s' % GITLAB_API_URL,
            'authorized': False
        }

@api.before_request
def get_secret_key():
    if 'private_token' in request.cookies:
        g.private_token = request.cookies['private_token']
    elif 'private_token' in request.args:
        g.private_token = request.args['private_token']
    else:
        g.private_token = False

@api.route('/api/v1/check')
def check():
    response = gitlab_get_api_request('user')
    resp = jsonify(authorized=response['authorized'])
    if 'error' in response:
        resp.status_code = 503
    return resp

@api.route('/api/v1/<path:resource>')
def get(resource):
    response = gitlab_get_api_request(resource)
    resp = jsonify(response)
    if 'error' in response:
        resp.status_code = 503
    return resp
