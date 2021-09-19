#!/usr/bin/python3
""" This Module contains Classes to work with User Access """

import hashlib
import os

import jwt
import mysql.connector
from jwt import DecodeError

USEFUL_KEY = 'my2w7wjd7yXF64FIADfJxNs1oupTGAuW'


class Driver:
    """ SQL connector to the application DBs """

    # This database data is here just for you to test, please, remember to define your own DB
    # You can test with username = admin, password = secret
    # This DB has already a best practice: a salt value to store the passwords

    def __init__(self) -> None:
        self.cnx = mysql.connector.connect(
            host='bootcamp-tht.sre.wize.mx',
            user=os.getenv('DB_USERNAME', 'secret'),
            password=os.getenv('DB_PASS', 'noPow3r'),
            database='bootcamp_tht'
        )

    def __enter__(self):
        return self

    def __exit__(self, *exc_details):
        self.cnx.close()


class Token:
    """ Handles Token related operations """

    # We'll refactor this to consume the Cursor
    # pylint: disable=too-few-public-methods

    @staticmethod
    def generate_token(username, password):
        """ The first endpoint receives a username and password.

        When these parameters are correct it returns a JWT token
        Otherwise it should return a 403 HTTP error message.

        :param username:
        :param password:
        :return:
        """
        jwt_token = None
        query = 'SELECT username, password, salt, role FROM users WHERE username = %s'
        with Driver() as driver:
            # Get cursor
            cursor = driver.cnx.cursor()
            # In Python, a tuple containing a single value must include a comma.
            # For example, ('abc') is evaluated as a scalar while ('abc',) is evaluated as a tuple.
            cursor.execute(query, (username,))
            for (q_username, q_password, salt, role) in cursor:
                # Passwords have appended the salt value and hashed with the SHA512 Algorithm
                salted_input = password + salt
                hash_value = hashlib.sha512(salted_input.encode()).hexdigest()

                if username == q_username and hash_value == q_password:
                    key = os.getenv('JWT_TOKEN', USEFUL_KEY)
                    jwt_token = jwt.encode({'role': role}, key, algorithm="HS256")
            cursor.close()

        return jwt_token


class Restricted:
    """ Validates Token and allows contents to be displayed """

    # We'll refactor this to consume the Cursor
    # pylint: disable=too-few-public-methods

    @staticmethod
    def access_data(authorization: str):
        """ Check if the role can access a resource

        :param authorization: Authorization Bearer Token
        :return: Whether or not the role can see the contents
        """
        # These values could come up from the DB
        valid_roles = ['admin', 'editor', 'viewer']

        # Validate inputs
        if not isinstance(authorization, str):
            return False

        # Sanitize
        authorization = authorization.strip()

        # Validate the authorization contains a prefix tag such as 'Bearer'
        if authorization.count(' ') != 1:
            return False

        scheme, token = authorization.split(' ')

        if scheme != 'Bearer:':
            return False

        try:
            key = os.getenv('JWT_TOKEN', USEFUL_KEY)
            payload = jwt.decode(token.encode(), key, algorithms='HS256')
        except DecodeError:
            return False

        role = payload.get('role', None)

        return role in valid_roles
