import os
import unittest
import numpy as np
from numpy.testing import assert_allclose

from cyrasterize import CyRasterizer


NO_DISPLAY = (os.environ.get('TRAVIS') or os.environ.get('IN_VM') or
              os.environ.get('JENKINS_URL'))


@unittest.skipIf(NO_DISPLAY, "requires a display")
def test_basic_random():
    c = CyRasterizer(width=100, height=100)

    points = np.array([[-1, -1, 0], [1, -1, 0], [1, 1, 0], [-1, 1, 0]])
    trilist = np.array([[0, 1, 2], [2, 3, 0]])
    colours = np.random.uniform(size=(100, 100, 3))
    tcoords = np.array([[0, 0], [1, 0], [1, 1], [0, 1]])

    rgb_image, float_image, mask = c.rasterize(points, trilist, colours,
                                               tcoords)

    assert_allclose(rgb_image, colours)
