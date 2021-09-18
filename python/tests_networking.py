#!/usr/bin/python3
""" This Module contains Test cases associated to subnet masks actions """

import unittest

from convert import cidr_to_mask, mask_to_cidr, ipv4_validation, INVALID


TEST_CASES = (
    ('255.255.255.255', '32'),
    ('255.255.255.254', '31'),
    ('255.255.255.252', '30'),
    ('255.255.255.248', '29'),
    ('255.255.255.240', '28'),
    ('255.255.255.224', '27'),
    ('255.255.255.192', '26'),
    ('255.255.255.128', '25'),
    ('255.255.255.0', '24'),
    ('255.255.254.0', '23'),
    ('255.255.252.0', '22'),
    ('255.255.248.0', '21'),
    ('255.255.240.0', '20'),
    ('255.255.224.0', '19'),
    ('255.255.192.0', '18'),
    ('255.255.128.0', '17'),
    ('255.255.0.0', '16'),
    ('255.254.0.0', '15'),
    ('255.252.0.0', '14'),
    ('255.248.0.0', '13'),
    ('255.240.0.0', '12'),
    ('255.224.0.0', '11'),
    ('255.192.0.0', '10'),
    ('255.128.0.0', '9'),
    ('255.0.0.0', '8'),
    ('254.0.0.0', '7'),
    ('252.0.0.0', '6'),
    ('248.0.0.0', '5'),
    ('240.0.0.0', '4'),
    ('224.0.0.0', '3'),
    ('192.0.0.0', '2'),
    ('128.0.0.0', '1'),
    ('0.0.0.0', '0'),
)


class CidrToMaskTestCase(unittest.TestCase):
    """ Test Cases for cidr_to_mask """

    def test_valid_cidr_to_mask(self):
        """ Assert a class A CIDR translates correctly """

        for test_case in TEST_CASES:
            mask, cidr = test_case
            with self.subTest(cidr):
                self.assertEqual(mask, cidr_to_mask(cidr))

    def test_valid_cidr_to_mask_integer(self):
        """ Assert a class A CIDR translates correctly """
        self.assertEqual(INVALID, cidr_to_mask(255))

    def test_valid_cidr_to_mask_not_digit(self):
        """ Assert a class A CIDR translates correctly """
        self.assertEqual(INVALID, cidr_to_mask('a'))

    def test_invalid_cidr_to_mask(self):
        """ Assert a edge cases """
        test_cases = ('-2', '-1', '33', '34')
        for cidr in test_cases:
            with self.subTest(cidr):
                self.assertEqual(INVALID, cidr_to_mask(cidr))


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


if __name__ == '__main__':  # pragma: no cover
    unittest.main()
