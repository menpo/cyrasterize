# distutils: language = c++

from libcpp cimport bool
cimport numpy as np
import logging as log
import os.path
import sys
import numpy as np

from .c_opengl cimport *
from .c_opengl_debug cimport *
from .shader import VertexShader, FragmentShader


SHADER_BASEPATH = os.path.join(os.path.dirname(sys.modules['cyrasterize'].__file__), 'shaders', 'blinnphong')
DEFAULT_VERTEX_SHADER_SRC = open(SHADER_BASEPATH + '.vert', 'rt').read()
DEFAULT_FRAGMENT_SHADER_SRC = open(SHADER_BASEPATH + '.frag', 'rt').read()

ctypedef void (*matrix_fun)(GLint, GLsizei, GLboolean, GLfloat *)


cdef class GLUniform:
    cdef GLuint location
    cdef np.ndarray value
    cdef str name
    valid_dtypes = (np.float32, np.int32)

    def __cinit__(self, str name, GLuint location, np.ndarray value):
        r'''A uniform opengl variable
        Parameters
        ----------

        name : str, the variable name as a string

        location: GLuint, the opengl specific identifier of the uniform

        value: ndarray, the value has to have a dtype which is a subclass
        of an int32 or a float32. This only accepts one of the following shapes:

            0,  : a single scalar
            1,  : a vector array
            2,2 : a 2x2 matrix array
            3,3 : a 3x3 matrix array
            4,4 : a 4x4 matrix array
        '''

        if not any([value.dtype == x for x in self.valid_dtypes]):
            raise ValueError('The value dtype must be either {}'.format(' or '.join(map(str, self.valid_dtypes))))

        self.name = name
        self.location = location
        self.value = value

    def __hash__(self):
        return self.location


    def __str__(self):
        return 'Name: {} Location: {} Type: {}'.format(self.name, self.location, self.value.dtype)

    cpdef upload(self):
        dtype = self.value.dtype
        cdef np.ndarray value = self.value
        cdef GLint vector_len = max(self.value.shape[0], 1)

        cdef matrix_fun matrix_funs[3]
        matrix_funs[0] = glUniformMatrix2fv
        matrix_funs[1] = glUniformMatrix3fv
        matrix_funs[2] = glUniformMatrix4fv

        vector_funs = [glUniform1f, glUniform1f, glUniform2f, glUniform3f, glUniform4f]

        if value.ndim <= 1:
            # value is a vector
            if vector_len <= 4:
                  vector_funs[vector_len](*([self.location] + list(self.value)))
            else:
                if dtype == np.float32:
                    glUniform1fv(self.location, <GLint>vector_len, <GLfloat*> value.data)

                elif dtype == np.int32:
                    glUniform1iv(self.location, <GLint>vector_len, <GLint*> value.data)

                else:
                    raise RuntimeError()

        else:
            # value is a matrix
            for num, i in enumerate(range(3), start=2):
                if num == value.shape[0] and num == value.shape[1]:
                    matrix_funs[i](self.location, 1, GL_TRUE, <GLfloat *> value.data)
                    return

            raise ValueError('Only supports 2x2, 3x3 and 4x4 float matrices')

    def get_value(self):
        return self.value

def normalize_v3(arr):
    ''' Normalize a numpy array of 3 component vectors shape=(n,3) '''
    lens = np.sqrt( arr[:,0]**2 + arr[:,1]**2 + arr[:,2]**2 )
    arr[:,0] /= lens
    arr[:,1] /= lens
    arr[:,2] /= lens
    return arr

cdef class GLScene:
    cdef GLuint program
    cdef GLuint fbo
    cdef bool success
    cdef glr_texture fb_rgb_target
    cdef glr_texture fb_f3v_target

    # store the pixels permanently
    cdef float[:, :, ::1] rgb_pixels
    cdef float[:, :, ::1] f3v_pixels

    cdef int width
    cdef int height

    cdef glr_textured_mesh mesh

    cdef dict shaders
    cdef dict uniforms

    cdef glr_glfw_context context

    def __cinit__(self, int width, int height):
        self.shaders = dict()
        self.width = width
        self.height = height

        self.context = glr_build_glfw_context_offscreen(width, height)
        # init our context
        cdef glr_STATUS status
        status = glr_glfw_init(&self.context)
        cdef bool success = status == GLR_SUCCESS


        if not success:
            raise RuntimeError('glr_glfw_init failed with error {}'.format(status))

        self.program = glCreateProgram()

        self.success = success

        self.rgb_pixels = np.empty((self.height, self.width, 4),
                                   dtype=np.float32)
        self.f3v_pixels = np.empty((self.height, self.width, 3),
                                   dtype=np.float32)

        cdef glr_texture fb_rgb_target = glr_build_float_rgba_texture(
            &self.rgb_pixels[0, 0, 0], self.width, self.height)


        cdef glr_texture fb_f3v_target = glr_build_float_rgb_texture(
            &self.f3v_pixels[0, 0, 0], self.width, self.height)

        self.fb_rgb_target = fb_rgb_target
        self.fb_f3v_target = fb_f3v_target

        self.init_frame_buffer()

    def attach_shaders(self, shaders):
        for shader in shaders:
            self.attach_shader(shader)

        glLinkProgram(self.program)


    def attach_shader(self, shader):
        '''
        Attaches a shader to the engine.

        Properties:

        shader: ShaderSource
        '''
        if not shader.is_compiled():
            raise ValueError('Shader not compiled!')

        if shader.get_type() in self.shaders:
            log.debug('Replacing existing shader!')

            glDetachShader(self.program, self.shaders[shader.get_type()].get_id())

        self.shaders[shader.get_type()] = shader

        glAttachShader(self.program, shader.get_id())
        log.debug(self.get_program_log())

        if not self.is_linked():
            self.uniforms = dict()

    cpdef get_uniform(self, name):
        try:
            return self.uniforms[name].get_value()
        except KeyError:
            return None

    cpdef set_uniform(self, name, value):
        value = np.asarray(value)

        cdef bytes c_name = name.encode('UTF-8')

        location = glGetUniformLocation(self.program, c_name)

        if location < 0:
            raise RuntimeError('The is no uniform named {} inside the source.'.format(name))

        uniform = GLUniform(name, location, value)

        log.debug('Uploading {}...'.format(uniform))

        glUseProgram(self.program)
        uniform.upload()
        glUseProgram(0)

        self.uniforms[name] = uniform


    cdef void init_frame_buffer(self):
        self.fb_rgb_target.unit = 0
        self.fb_f3v_target.unit = 0

        glr_init_texture(&self.fb_rgb_target)
        glr_init_texture(&self.fb_f3v_target)


        glGenFramebuffers(1, &self.fbo)

        glr_init_framebuffer(&self.fbo, &self.fb_rgb_target, GL_COLOR_ATTACHMENT0)

        glr_init_framebuffer(&self.fbo, &self.fb_f3v_target, GL_COLOR_ATTACHMENT1)

        cdef GLenum buffers[2]

        for i in range(2):
            buffers[i] = (GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1)[i]

        glr_register_draw_framebuffers(self.fbo, 2, buffers)

        cdef GLuint depth_buffer;

        glGenRenderbuffers(1, &depth_buffer)

        glBindRenderbuffer(GL_RENDERBUFFER, depth_buffer)
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT,
                self.fb_rgb_target.width, self.fb_rgb_target.height)
        glBindFramebuffer(GL_FRAMEBUFFER, self.fbo)
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT,
                GL_RENDERBUFFER, depth_buffer)

        # THIS BEING GL_DEPTH_COMPONENT means that the depth information at each
        # fragment will end up here. Note that we must manually set up the depth
        # buffer when using framebuffers.

        cdef GLenum status;
        status = glCheckFramebufferStatus(GL_FRAMEBUFFER)

        if(status != GL_FRAMEBUFFER_COMPLETE):
            log.error(self.get_program_log())
            glr_check_error()
            raise RuntimeError("Framebuffer error: %d 0x%04X" % (status, status))

        glBindFramebuffer(GL_FRAMEBUFFER, 0)

    cdef bool is_linked(self):
        cdef GLint result = 0
        glGetProgramiv(self.program, GL_LINK_STATUS, &result)

        return result == GL_TRUE

    cdef void stop(self):
        '''
            Stop using the program
        '''
        glUseProgram(0)


    cdef get_program_log(self):
        '''
            Return the program log.
        '''

        cdef char msg[2048]
        cdef GLsizei length
        msg[0] = '\0'

        glGetProgramInfoLog(self.program, 2048, &length, msg)

        cdef bytes ret = msg[:length]
        return ret.split(b'\0')[0].decode('utf-8')

    def render_scene(self):
        glUseProgram(self.program)

        # now we have an instantiated glr_textured_mesh, we have to choose
        # some the OpenGL properties and set them. We decide that the vertices
        # should be bound to input 0 into the shader, while tcoords should be
        # input 1, and the float 3 vec is 2.

        self.mesh.vertices.attribute_pointer = 0
        self.mesh.tcoords.attribute_pointer = 1
        self.mesh.f3v_data.attribute_pointer = 2
        self.mesh.normals.attribute_pointer = 3

        # assign the meshes texture to be on unit 1 and initialize the buffer for
        # texture mesh
        self.mesh.texture.unit = 1

        glr_init_vao(&self.mesh)
        glr_check_error()

        glr_init_texture(&self.mesh.texture)
        glr_check_error()

        glBindFramebuffer(GL_FRAMEBUFFER, self.fbo)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)

        cdef uniform = glGetUniformLocation(self.program, "textureImage")
        glUniform1i(uniform, self.mesh.texture.unit)

        # and tcoords are all bound to the attributes and ready to go
        glBindVertexArray(self.mesh.vao)
        glDrawElements(GL_TRIANGLES, self.mesh.trilist.n_vectors * 3,
                GL_UNSIGNED_INT, <GLvoid*> 0)

        # 3. DETATCH + SWAP BUFFERS
        # now we're done, can disable the vertex array (for safety)
        glBindVertexArray(0)

        cdef GLFWwindow* window = <GLFWwindow*> self.context.window

        glfwSwapBuffers(<GLFWwindow *> window)

        glBindFramebuffer(GL_FRAMEBUFFER, 0)

        glr_destroy_vbos_on_trianglar_mesh(&self.mesh)
        glDeleteTextures(1, &self.mesh.texture.id)


    def get_active_uniforms(self):
        cdef int total = -1;
        glGetProgramiv(self.program, GL_ACTIVE_UNIFORMS, &total)

        cdef int name_len
        cdef GLint num
        cdef GLenum _type = GL_ZERO
        cdef char name[256];

        cdef uniforms = []

        for t in range(total):
            glGetActiveUniform(self.program, <GLuint> t, sizeof(name)-1,
                &name_len, &num, &_type, name)

            name[name_len] = 0
            # .decode('utf8') to go to unicode, then cast to str -
            # in Python 2.7 this is back to bytes, in Py 3 stays as unicode.
            uniforms.append(str(name.decode('utf8')))

        return uniforms

    def render_offscreen_rgb(self,
            np.ndarray[float, ndim=2, mode="c"] points not None,
            np.ndarray[float, ndim=2, mode="c"] f3v_data not None,
            np.ndarray[unsigned, ndim=2, mode="c"] trilist not None,
            np.ndarray[float, ndim=2, mode="c"] tcoords not None,
            np.ndarray[float, ndim=3, mode="c"] texture not None):

        #Create a zeroed array with the same type and shape as our vertices i.e., per vertex normal
        cdef np.ndarray[float, ndim=2, mode="c"] norm = np.zeros( (points.shape[0], points.shape[1]), dtype=np.float32)
        tris = points[trilist]
        #Calculate the normal for all the triangles, by taking the cross product of the vectors v1-v0, and v2-v0 in each triangle
        n = np.cross( tris[::,1 ] - tris[::,0]  , tris[::,2 ] - tris[::,0] )

        # n is now an array of normals per triangle. The length of each normal is dependent the vertices,
        # we need to normalize these, so that our next step weights each normal equally.

        normalize_v3(n)

        # now we have a normalized array of normals, one per triangle, i.e., per triangle normals.
        # But instead of one per triangle (i.e., flat shading), we add to each vertex in that triangle,
        # the triangles' normal. Multiple triangles would then contribute to every vertex, so we need to normalize again afterwards.
        # The cool part, we can actually add the normals through an indexed view of our (zeroed) per vertex normal array

        norm[ trilist[:,0] ] += n
        norm[ trilist[:,1] ] += n
        norm[ trilist[:,2] ] += n
        normalize_v3(norm)


        self.mesh = glr_build_f3_f3_rgb_float_mesh(
            &points[0, 0], &norm[0, 0], &f3v_data[0, 0], points.shape[0],
            &trilist[0, 0], trilist.shape[0], &tcoords[0, 0],
            &texture[0, 0, 0], texture.shape[1], texture.shape[0])

        self.render_scene()

        glr_get_framebuffer(&self.fb_rgb_target)
        glr_get_framebuffer(&self.fb_f3v_target)

        return np.array(self.rgb_pixels), np.array(self.f3v_pixels)

    cpdef set_clear_color(self, np.ndarray[float, ndim=1, mode='c'] clear_c):
        if clear_c.size != 4:
            raise ValueError("colour vector must be 4 elements long")
        glr_set_clear_color(&clear_c[0])

    cpdef get_clear_color(self):
        cdef np.ndarray[float, ndim=1, mode='c'] clear_color
        clear_color = np.empty(4, dtype=np.float32)
        glr_get_clear_color(&clear_color[0])
        return clear_color

    def get_width(self):
        return self.context.window_width

    def get_height(self):
        return self.context.window_height

    def __del__(self):
        glr_glfw_terminate(&self.context)

    def successfully_initialized(self):
        return self.success

    def reset_view(self):
        orthogonal = np.require(np.eye(4), dtype=np.float32, requirements='C')

        self.set_model_matrix(orthogonal)
        self.set_view_matrix(orthogonal)
        self.set_projection_matrix(orthogonal)

cdef class GLRasterizer(GLScene):

    def __init__(self, int width, int height):
        default_vertex_shader = VertexShader(DEFAULT_VERTEX_SHADER_SRC)
        default_fragment_shader = FragmentShader(DEFAULT_FRAGMENT_SHADER_SRC)

        self.attach_shaders((default_vertex_shader, default_fragment_shader))

        # Initialise camera/projection matrices
        self.reset_view()

    cpdef get_model_matrix(self):
        return self.get_uniform('modelMatrix')

    cpdef get_view_matrix(self):
        return self.get_uniform('viewMatrix')

    cpdef get_projection_matrix(self):
        return self.get_uniform('projectionMatrix')

    def get_compound_matrix(self):
        M = self.get_model_matrix()
        V = self.get_view_matrix()
        P = self.get_projection_matrix()

        return P.dot(V).dot(M)

    cpdef set_model_matrix(self,
                           np.ndarray[float, ndim=2, mode="c"] m):
        self.set_uniform('modelMatrix', m)

    cpdef set_view_matrix(self,
                          np.ndarray[float, ndim=2, mode="c"] m):

        self.set_uniform('viewMatrix', m)

    cpdef set_projection_matrix(self,
                    np.ndarray[float, ndim=2, mode="c"] m):

        return self.set_uniform('projectionMatrix', m)
