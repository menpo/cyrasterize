import numpy as np
from cyrasterize import CyRasterizer
from numpy.testing import assert_allclose
import os

def test_basic_random():
    c = CyRasterizer(width=100, height=100)

    points = np.array([[-1, -1, 0], [1, -1, 0], [1, 1, 0], [-1, 1, 0]])
    trilist = np.array([[0, 1, 2], [2, 3, 0]])
    colours = np.random.uniform(size=(100, 100, 3))
    tcoords = np.array([[0, 0], [1, 0], [1, 1], [0, 1]])

    rgb_image, float_image, mask = c.rasterize(points, trilist, colours, tcoords)
    
    assert_allclose(rgb_image, colours)


if __name__ == "__main__":
    if os.environ.get('IN_VM') is None:
        test_basic_random()
