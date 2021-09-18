#!/usr/bin/python3
""" This Module contains Test cases associated to Login actions """

import unittest
from unittest.mock import patch

from jwt import DecodeError
from werkzeug.exceptions import Forbidden

from methods import Token, Restricted

TOKEN = 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiYWRtaW4ifQ' \
        '.BmcZ8aB5j8wLSK8CqdDwkGxZfFwM1X1gfAIN7cXOx9w'
BEARER_TOKEN = 'Bearer: ' + TOKEN


class TokenTestCase(unittest.TestCase):
    """ Test cases related to Token """

    def setUp(self):
        self.convert = Token()

    def test_generate_token(self):
        """ Assert that the correct TOKEN is generated by a known source of roles """
        self.assertEqual(TOKEN, self.convert.generate_token('admin', 'secret'))

    def test_generate_token_not_found(self):
        """ Sending a non matching password returns Forbidden """
        with self.assertRaises(Forbidden):
            self.assertEqual(TOKEN, self.convert.generate_token('noadmin', 'secret'))


class RestrictedTestCase(unittest.TestCase):
    """ Test cases related to Restricted """

    def setUp(self):
        self.validate = Restricted()

    def test_access_data(self):
        """ Asserts a role have privilege access granted """
        self.assertTrue(self.validate.access_data(BEARER_TOKEN))

    def test_access_data_none(self):
        """ Asserts sending a None value returns a false """
        self.assertFalse(self.validate.access_data(None))

    def test_access_data_corrupt(self):
        """ Changing one character returns a False """
        corrupt_token = TOKEN[0:-1] + 'a'
        self.assertFalse(self.validate.access_data(corrupt_token))

    def test_access_data_invalid_schema(self):
        """ Not sending the flag 'Bearer' sends an Unauthorized """
        invalid_schema_token = BEARER_TOKEN.replace('Bearer:', 'Token:')
        self.assertFalse(self.validate.access_data(invalid_schema_token))

    def test_access_data_no_bearer(self):
        """ Not sending the flag 'Bearer' sends an Unauthorized """
        self.assertFalse(self.validate.access_data('fyJh.eyb2'))

    @patch('jwt.decode')
    def test_access_data_decode_error(self, jwt_decode_mock):
        """ Handle failures on DecodeError """
        jwt_decode_mock.side_effect = DecodeError()
        self.assertFalse(self.validate.access_data(BEARER_TOKEN))


if __name__ == '__main__':  # pragma: no cover
    unittest.main()
