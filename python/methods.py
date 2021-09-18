#!/usr/bin/python3
""" This Module contains Classes to work with User Access """

import hashlib
import jwt
from jwt import DecodeError


USEFUL_KEY = 'my2w7wjd7yXF64FIADfJxNs1oupTGAuW'


class Token:
    """ Handles Token related operations """

    # We'll refactor this to consume the Cursor
    # pylint: disable=too-few-public-methods

    @staticmethod
    def generate_token(username, input_password, query):
        """

        :param username:
        :param input_password:
        :param query:
        :return:
        """

        if query is not None:
            salt = query[0][0]
            password = query[0][1]
            role = query[0][2]
            hash_pass = hashlib.sha512((input_password + salt).encode()).hexdigest()
            if hash_pass == password:
                en_jwt = jwt.encode({"role": role}, USEFUL_KEY, algorithm='HS256')
                return en_jwt
            return username

        return username


class Restricted:
    """ Validates Token and allows contents to be displayed """

    # We'll refactor this to consume the Cursor
    # pylint: disable=too-few-public-methods

    @staticmethod
    def access_data(authorization):
        """ Return if the token is an recognized role """
        try:
            authorization = authorization.replace('Bearer', '')[2:-1]
            var1 = jwt.decode(authorization, USEFUL_KEY, algorithms='HS256')
        except DecodeError:
            return False

        return 'role' in var1
