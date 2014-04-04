import numpy as np

from cyrasterize.glrasterizer import GLRasterizer


class CyRasterizerBase(object):
    r"""Offscreen OpenGL rasterizer of fixed width and height.

    Parameters
    ----------

    width : int
        The width of the rasterize target

    height: int
        The height of hte rasterize target


    Notes
    -----

    For a given vertex v = (x, y, z, 1), it's position in image space
    v' = (s, t) is calculated from

    v' = P * V * M * v

    where:

    M is the model matrix
    V is the view matrix (view the world from the position of the camera)
    P is the projection matrix (usually an orthographic or perspective
    matrix)

    All matrices are 4x4 floats, as in OpenGL all points are treated as
    homogeneous.

    Note that this is the raw code written in the shader. The usual
    pipeline of OpenGL applies - perspective division is performed to
    form a clip space, and z-buffering is used to mask pixels
    appropriately.

    Texture information in the form of a texture map and normalized
    per-vertex texture coordinates) are used to source colour values.

    An arbitrary float 3-vector (f3v) can also be set on each vertex.
    This value is passed through the same pipeline and interpolated but
    note that the MATRICES ABOVE ARE NOT APPLIED TO THIS DATA.

    This can be useful for example for passing through the shape
    information of an object into the rendered image domain.
    Note that because of the above statement, the shape information
    rendered would be in the objects original space, not in camera space
    (i.e. the z value will not correlate to a depth buffer).

    """

    def __init__(self, width=1024, height=768, model_matrix=None,
                 view_matrix=None, projection_matrix=None):
        self._opengl = GLRasterizer(width, height)
        if not self._opengl.successfully_initialized():
            raise RuntimeError("Failed to initialize CyRasterizer")
        if model_matrix is not None:
            self.set_model_matrix(model_matrix)
        if view_matrix is not None:
            self.set_view_matrix(view_matrix)
        if projection_matrix is not None:
            self.set_projection_matrix(projection_matrix)

    @property
    def width(self):
        return self._opengl.get_width()

    @property
    def height(self):
        return self._opengl.get_height()

    @property
    def model_matrix(self):
        return self._opengl.get_model_matrix()

    @property
    def view_matrix(self):
        return self._opengl.get_view_matrix()

    @property
    def projection_matrix(self):
        return self._opengl.get_projection_matrix()

    # we don't use setters here as we want to be clear on when we give C a
    # new matrix (e.g. rasterizer.model_matrix[:, 2] = 2 would not be caught
    # by the setter)
    def set_model_matrix(self, value):
        value = _verify_opengl_homogeneous_matrix(value)
        self._opengl.set_model_matrix(value)

    def set_view_matrix(self, value):
        value = _verify_opengl_homogeneous_matrix(value)
        self._opengl.set_view_matrix(value)

    def set_projection_matrix(self, value):
        value = _verify_opengl_homogeneous_matrix(value)
        self._opengl.set_projection_matrix(value)

    def _rasterize(self, points, trilist, texture, tcoords,
                   per_vertex_f3v=None):
        r"""Rasterizes a textured mesh along with some float interpolant data
        through OpenGL.

        Parameters
        ----------
        points : ndarray, shape (n_points, 3)
            The coordinates of points that need to be rasterized

        trilist: ndarray, shape (n_tris, 3)
            The connectivity information of the triangulation

        texture: ndarray, shape (texture_width, texture_height, 3)
            An RGB texture floating point image (pixel values in range [0, 1]

        tcoords: ndarray, shape (n_points, 2)
            Per vertex texture coordinates given in the normalized range [0, 1]

        per_vertex_f3v: ndarray, shape (n_points, 3), optional
            A matrix specifying arbitrary 3 floating point numbers per
            vertex. This data will be linearly interpolated across triangles
            and returned in the f3v image.

            Default None - points (shape information) used instead.

        Returns
        -------
        rgb_image : ndarray
            The rasterized image returned from OpenGL. Note that the
            behavior of the rasterization is governed by the projection,
            rotation and view matrices that may be set on this class,
            as well as the width and height of the rasterization, which is
            determined on the creation of this class.

        f3v_image : ndarray
            The rasterized float interpolant from OpenGL. Note that the
            behavior of the rasterization is governed by the projection,
            rotation and view matrices that may be set on this class,
            as well as the width and height of the rasterization, which is
            determined on the creation of this class.

        mask : ndarray
            Mask showing what true values the rasterizer wrote to.

        """
        points = np.require(points, dtype=np.float32, requirements='c')
        trilist = np.require(trilist, dtype=np.uint32, requirements='c')
        texture = np.require(texture, dtype=np.float32, requirements='c')
        tcoords = np.require(tcoords, dtype=np.float32, requirements='c')
        if per_vertex_f3v is None:
            per_vertex_f3v = points
        interp = np.require(per_vertex_f3v, dtype=np.float32, requirements='c')
        rgb_fb, f3v_fb = self._opengl.render_offscreen_rgb(points, interp,
                                                           trilist, tcoords,
                                                           texture)
        mask = rgb_fb[..., 3].astype(np.bool)
        return rgb_fb[..., :3].copy(), f3v_fb, mask


# Maintain a subclass here to allow other subclasses of CyRasterizerBase that
# expose different clean rasterization interfaces (e.g. we might want to define
# rasterize() in a more intelligent manor in Menpo)
class CyRasterizer(CyRasterizerBase):

    def rasterize(self, points, trilist, texture, tcoords, per_vertex_f3v=None):
        r"""Rasterizes a textured mesh along with some float interpolant data
        through OpenGL.

        Parameters
        ----------
        points : ndarray, shape (n_points, 3)
            The coordinates of points that need to be rasterized

        trilist: ndarray, shape (n_tris, 3)
            The connectivity information of the triangulation

        texture: ndarray, shape (texture_width, texture_height, 3)
            An RGB texture floating point image (pixel values in range [0, 1]

        tcoords: ndarray, shape (n_points, 2)
            Per vertex texture coordinates given in the normalized range [0, 1]

        per_vertex_f3v: ndarray, shape (n_points, 3), optional
            A matrix specifying arbitrary 3 floating point numbers per
            vertex. This data will be linearly interpolated across triangles
            and returned in the f3v image.

            Default None - points (shape information) used instead.

        Returns
        -------
        rgb_image : ndarray
            The rasterized image returned from OpenGL. Note that the
            behavior of the rasterization is governed by the projection,
            rotation and view matrices that may be set on this class,
            as well as the width and height of the rasterization, which is
            determined on the creation of this class.

        f3v_image : ndarray
            The rasterized float interpolant from OpenGL. Note that the
            behavior of the rasterization is governed by the projection,
            rotation and view matrices that may be set on this class,
            as well as the width and height of the rasterization, which is
            determined on the creation of this class.

        mask : ndarray
            Mask showing what true values the rasterizer wrote to.

        """
        return self._rasterize(points, trilist, texture, tcoords,
                               per_vertex_f3v=per_vertex_f3v)


def _verify_opengl_homogeneous_matrix(matrix):
    if matrix.shape != (4, 4):
        raise ValueError("OpenGL matrices must have shape (4,4)")
    return np.require(matrix, dtype=np.float32, requirements='C')
