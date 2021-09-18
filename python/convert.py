#!/usr/bin/python3
""" This module contains utilities to convert and validate CIDR and Network Masks in IPv4 """

MIN_BITS = 0
MAX_BITS = 32
MAX_IP = (2 ** MAX_BITS)
BITS_BY_BLOCK = 8
BLOCK_MASK = (2 ** BITS_BY_BLOCK) - 1
STEPS = MAX_BITS // BITS_BY_BLOCK
INVALID = 'Invalid'


def cidr_to_mask(cidr: str):
    """ Convert from Classless Interdomain Routing (CIDR) to Mask

    :param cidr: A string containing the number of bits to mask
    :param cidr: A string containing the number of bits to mask
    :return: A str representing the number of bits enabled to 1
    """
    if not isinstance(cidr, str):
        return INVALID

    if not cidr.isnumeric():
        return INVALID

    # Convert to integer to manipulate bits
    cidr_bits = int(cidr)
    if MIN_BITS <= cidr_bits <= MAX_BITS:
        # Calculate the complement to 1
        mask_in_int = MAX_IP - (2 ** (MAX_BITS - cidr_bits))

        # We iterate in the number of blocks define by BITS_BY_BLOCK
        # For every block we perform an AND with the maximum allowed value
        queue = []  # collector
        for _ in range(1, MAX_BITS, BITS_BY_BLOCK):
            queue.append(mask_in_int & BLOCK_MASK)
            mask_in_int = mask_in_int >> BITS_BY_BLOCK

        # The values were calculated using least significant bit so we have to reverse them
        mask = '.'.join(str(block) for block in reversed(queue))
    else:
        mask = INVALID

    return mask


def mask_to_cidr(mask):
    """

    :param mask:
    :return:
    """
    return mask


def ipv4_validation(ipv4):
    """

    :param ipv4:
    :return:
    """
    return ipv4
