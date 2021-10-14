#!/usr/bin/python3
""" This module contains utilities to retrieve the application versions from multiple sources """
import os

UNKNOWN = 'unknown'


def get_app_version():
    """ Retrieves the version of the application """

    # Get the container ID from the environment
    commit_sha = os.getenv('COMMIT_SHA', UNKNOWN)

    # This version is compose of the commit_sha
    version = f"{commit_sha}"

    return version
