import numpy as np
import os
import sys
from cyrasterize import CyRasterizer
from numpy.testing import assert_allclose

SHADER_BASEPATH = os.path.join(os.path.dirname(sys.modules['cyrasterize'].__file__), 'shaders', 'texture_shader')
DEFAULT_VERTEX_SHADER_SRC = open(SHADER_BASEPATH + '.vert', 'rb').read()
DEFAULT_FRAGMENT_SHADER_SRC = open(SHADER_BASEPATH + '.frag', 'rb').read()


def test_basic_random():
    c = CyRasterizer(width=100, height=100)

    # Set the vanilla texture shader
    c.set_shaders(vertex=DEFAULT_VERTEX_SHADER_SRC, fragment=DEFAULT_FRAGMENT_SHADER_SRC)

    points = np.array([[-1, -1, 0], [1, -1, 0], [1, 1, 0], [-1, 1, 0]])
    trilist = np.array([[0, 1, 2], [2, 3, 0]])
    colours = np.random.uniform(size=(100, 100, 3))
    tcoords = np.array([[0, 0], [1, 0], [1, 1], [0, 1]])

    rgb_image, float_image, mask = c.rasterize(points, trilist, colours, tcoords)

    assert_allclose(rgb_image, colours)
