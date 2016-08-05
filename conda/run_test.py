import os
from cyrasterize.tests import test_basic_random

if __name__ == "__main__":
    if (os.environ.get('IN_VM') is None and
        os.environ.get('TRAVIS') is None and
        os.environ.get('APPVEYOR') is None and
        os.environ.get('CI') is None) and
        'JENKINS_URL' not in os.environ:
        test_basic_random()
