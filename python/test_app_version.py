#!/usr/bin/python3
""" This Module contains Test cases associated to Version actions """
import os
import unittest
from unittest import mock

from app_version import get_app_version, UNKNOWN

COMMIT_SHA = 'b701977cdc0109a529bf78bf913d7299eaf00b91'


class GetAppVersionTestCase(unittest.TestCase):
    """ Test for getting the version string """

    def test_get_app_version(self):
        """ Default call should not fail and return an unknown """
        version = get_app_version()

        self.assertEqual(UNKNOWN, version)

    @mock.patch.dict(os.environ, dict(COMMIT_SHA=COMMIT_SHA), clear=True)
    def test_get_app_version_sha(self):
        """ Default call should not fail and return an unknown """
        version = get_app_version()

        self.assertEqual(COMMIT_SHA, version)


if __name__ == '__main__':  # pragma: no cover
    unittest.main()
