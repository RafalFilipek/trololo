# -*- coding: utf8 -*-

from flask import Blueprint
from flask import request
from flask import jsonify
from flask import current_app
from flask import g

import requests

api = Blueprint('api', __name__)

def gitlab_get_api_request(path, **params):
    if g.private_token is False:
        return { 'authorized': False }
    else:
        params['private_token'] = g.private_token
    try:
        url = '%s/%s/' % (current_app.config['GITLAB_API_URL'], path)
        r = requests.get(url, params=params, verify=False)
        resp = r.json()
        print resp
        if 'message' in resp and resp['message'] == '401 Unauthorized':
            return { 'authorized': False }
        else:
            return {
                'authorized': True,
                'data': resp
            }
    except requests.exceptions.RequestException:
        return {
            'error': 'Błąd podczas połączenia z %s' % current_app.config['GITLAB_API_URL'],
            'authorized': False
        }

@api.before_request
def get_private_token():
    print request.args
    if 'private_token' in request.args:
        g.private_token = request.args['private_token']
    elif 'private_token' in request.cookies:
        g.private_token = request.cookies['private_token']
    else:
        g.private_token = False

@api.route('/api/v1/check')
def check():
    response = gitlab_get_api_request('user')
    resp = jsonify(authorized=response['authorized'])
    return resp

@api.route('/api/v1/projects')
def get_projects():
    """
    GitLab API can fetch max. 100 projects per page so we need
    some 'while' magic to get all user projects.

    PS. Yep, I have over 140 projects.
    """
    page = 1
    has_more = True
    projects = []
    authorized = True

    while has_more is True:
        response = gitlab_get_api_request('projects', page=page, per_page = 100)
        current_page_projects = response['data']
        count = len(response['data'])
        authorized = authorized and response['authorized']
        if count > 0:
            projects.extend(current_page_projects)
        if not count == 100:
            has_more = False
        else:
            page += 1

    resp = jsonify({
        'authorized': authorized,
        'data': projects if authorized is True else []
    })
    return resp

@api.route('/api/v1/<path:path>')
def get(path):
    response = gitlab_get_api_request(path)
    resp = jsonify(response)
    return resp
