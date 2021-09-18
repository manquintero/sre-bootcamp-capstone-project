#!/usr/bin/python3
""" SRE-BOOTCAMP-CAPSTONE-PROJECT """
import mysql.connector
from flask import Flask, jsonify, abort, request

from convert import mask_to_cidr, cidr_to_mask
from methods import Token, Restricted

app = Flask(__name__)
login = Token()
protected = Restricted()


# Just a health check
@app.route("/")
def url_root():
    """ Homepage """
    return "OK"


# Just a health check
@app.route("/_health")
def url_health():
    """ Entrypoint for automated health checks """
    return "OK"


# e.g. http://127.0.0.1:8000/login
@app.route("/login", methods=['POST'])
def url_login():
    """ Login page for POST verbs """
    var1 = request.form['username']
    var2 = request.form['password']
    # This database data is here just for you to test, please, remember to define your own DB
    # You can test with username = admin, password = secret
    # This DB has already a best practice: a salt value to store the passwords
    con = mysql.connector.connect(
        host='bootcamp-tht.sre.wize.mx',
        user='secret',
        password='noPow3r',
        database='bootcamp_tht'
    )
    cursor = con.cursor()
    cursor.execute(f"SELECT salt, password, role from users where username ='{var1}';")
    rows = cursor.fetchall()
    var3 = login.generateToken(var1, var2, rows)
    if not var3:
        abort(401)
    response = {"data": var3}
    return jsonify(response)


# e.g. http://127.0.0.1:8000/cidr-to-mask?value=8
@app.route("/cidr-to-mask")
def url_cidr_to_mask():
    """ Convert CIDR to their equivalent in subnet masks """
    var1 = request.headers.get('Authorization')
    if not protected.access_Data(var1):
        abort(401)
    val = request.args.get('value')
    response = {"function": "cidrToMask", "input": val, "output": cidr_to_mask(val), }
    return jsonify(response)


# # e.g. http://127.0.0.1:8000/mask-to-cidr?value=255.0.0.0
@app.route("/mask-to-cidr")
def url_mask_to_cidr():
    """ Convert subnet masks to their equivalent in CIDR """
    var1 = request.headers.get('Authorization')
    if not protected.access_Data(var1):
        abort(401)
    val = request.args.get('value')
    response = {"function": "maskToCidr", "input": val, "output": mask_to_cidr(val), }
    return jsonify(response)


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)
