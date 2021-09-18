#!/usr/bin/python3
""" This Module contains Test cases associated to subnet masks actions """

import unittest

from convert import cidr_to_mask, mask_to_cidr, ipv4_validation


class CidrToMaskTestCase(unittest.TestCase):
    """ Test Cases for cidr_to_mask """

    def test_valid_cidr_to_mask(self):
        """ Assert a class A CIDR translates correctly """
        self.assertEqual('128.0.0.0', cidr_to_mask('1'))

    def test_invalid_cidr_to_mask(self):
        """ Assert for Invalid inputs """
        self.assertEqual('Invalid', cidr_to_mask('0'))


class MaskToCidrTestCase(unittest.TestCase):
    """ Test Cases for mask_to_cidr """

    def test_valid_mask_to_cidr(self):
        """ Assert for Valid Mask to Class A CIDR """
        self.assertEqual('1', mask_to_cidr('128.0.0.0'))

    def test_invalid_mask_to_cidr(self):
        """ Assert an Invalid Maks is set to CIDR """
        self.assertEqual('Invalid', mask_to_cidr('0.0.0.0'))


class IPV4ValidationTestCase(unittest.TestCase):
    """ Test Cases for ipv4_validation """

    def test_valid_ipv4(self):
        """ Validates an IPV4 format """
        self.assertTrue(ipv4_validation('127.0.0.1'))

    def test_invalid_ipv4(self):
        """ Validates an invalid IPV4 format """
        self.assertFalse(ipv4_validation('192.168.1.2.3'))


if __name__ == '__main__':
    unittest.main()
