#!/usr/bin/python3
""" SRE-BOOTCAMP-CAPSTONE-PROJECT """
from http.client import UNAUTHORIZED, FORBIDDEN

from flask import Flask, jsonify, abort, request

from app_version import get_app_version
from convert import mask_to_cidr, cidr_to_mask
from methods import Token, Restricted

app = Flask(__name__)
login = Token()
protected = Restricted()


# Just a health check
@app.route("/")
def url_root():
    """ Homepage """
    return "ok"


# Retrieves the container and app version
@app.route("/version")
def url_version():
    """ Exposes the application version """
    return get_app_version()


# Just a health check
@app.route("/_health")
def url_health():
    """ Entrypoint for automated health checks """
    return "HEALTHY"


# e.g. http://127.0.0.1:8000/login
@app.route("/login", methods=['POST'])
def url_login():
    """ Login page for POST verbs """
    if 'username' not in request.form or 'password' not in request.form:
        abort(FORBIDDEN)
    username = request.form['username']
    password = request.form['password']
    token = login.generate_token(username, password)
    if not token:
        abort(FORBIDDEN)
    response = dict(data=token)
    return jsonify(response)


# e.g. http://127.0.0.1:8000/cidr-to-mask?value=8
@app.route("/cidr-to-mask")
def url_cidr_to_mask():
    """ Convert CIDR to their equivalent in subnet masks """
    authorization = request.headers.get('Authorization')
    if not protected.access_data(authorization):
        abort(UNAUTHORIZED)

    value = request.args.get('value')
    mask = cidr_to_mask(value)
    response = dict(function='cidrToMask', input=value, output=mask)
    return jsonify(response)


# # e.g. http://127.0.0.1:8000/mask-to-cidr?value=255.0.0.0
@app.route("/mask-to-cidr")
def url_mask_to_cidr():
    """ Convert subnet masks to their equivalent in CIDR """
    authorization = request.headers.get('Authorization')
    if not protected.access_data(authorization):
        abort(UNAUTHORIZED)
    value = request.args.get('value')
    response = dict(function="maskToCidr", input=value, output=mask_to_cidr(value))
    return jsonify(response)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)
