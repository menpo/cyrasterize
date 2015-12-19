# distutils: language = c++

from libc.stdint cimport uint8_t
from libcpp cimport bool
from libc.stdio cimport printf
from c_opengl cimport *
from c_opengl_debug cimport *
from shader import VertexShader, FragmentShader

cimport numpy as np
import numpy as np

import os.path
import sys


SHADER_BASEPATH = os.path.join(os.path.dirname(sys.modules['cyrasterize'].__file__), 'shaders', 'texture_shader')
DEFAULT_VERTEX_SHADER_SRC = open(SHADER_BASEPATH + '.vert', 'rb').read()
DEFAULT_FRAGMENT_SHADER_SRC = open(SHADER_BASEPATH + '.frag', 'rb').read()


cdef float* ndarray_vector_to_c_float_array(ar):
    ar = ar.ravel()

    cdef float* c_array = <float *>malloc(ar.shape[0] * sizeof(float))

    if c_array is NULL:
        raise MemoryError()

    for i in xrange(ar.shape[0]):
        c_array[i] = <float>ar[i]

    return c_array

cdef int* ndarray_vector_to_c_int_array(ar):
    ar = ar.ravel()

    cdef int* c_array = <int *>malloc(ar.shape[0] * sizeof(int))

    if c_array is NULL:
        raise MemoryError()

    for i in xrange(ar.shape[0]):
        c_array[i] = <int>ar[i]

    return c_array

cdef class GLUniform:
    cdef GLuint location
    cdef np.ndarray value
    cdef str name

    def __cinit__(self, str name, GLuint location, np.ndarray value):
        r'''A uniform opengl variable
        Parameters
        ----------

        name : str, the variable name as a string

        location: GLuint, the opengl specific identifier of the uniform

        value: ndarray, the value has to have a dtype which is a subclass
        of an int or a float. This only accepts one of the following shapes:

            0,  : a single float
            1,  : a vector array
            2,2 : a 2x2 matrix array
            3,3 : a 2x2 matrix array
            4,4 : a 2x2 matrix array
        '''

        self.name = name
        self.location = location
        self.value = value

    def __hash__(self):
        return self.location

    def get_type_name(self):
        dtype = self.value.dtype
        valid_types = [(float, 'f'), (int, 'i')]

        try:
            type_name = filter(lambda x: x[0],
                [(np.issubdtype(dtype, stype), name) for stype, name in valid_types]
            )[0][1]
        except IndexError:
            raise ValueError('Can not upload an {} array. Only arrays of ints and floats.'.format(self.value.dtype))

        return type_name

    def __str__(self):

        return 'Name: {} Location: {} Type: {}'.format(self.name, self.location, self.get_type_name())

    cpdef upload(self):
        dtype = self.value.dtype
        cdef np.ndarray value = self.value
        cdef float* f_array
        cdef int* i_array
        cdef float[:, :] fmatrix

        fun_basename = 'glUniform'
        type_name = self.get_type_name()

        cdef GLint vector_len = max(self.value.shape[0], 1)

        if value.ndim <= 1:
            # Value is a vector
            # map2fun = [glUniform1f, 1f, glUniform2f, glUniform3f, glUniform4f]

            if vector_len <= 4:

                fun_name = "{}{}{}".format(fun_basename, vector_len, type_name)

                globals()[fun_name](*([self.location] + list(self.value)))
            else:

                # glUniform1iv
                fun_name = "{}{}{}v".format(fun_basename, 1, type_name)

                fun = globals()[fun_name]
                if type_name == 'f':
                    f_array = ndarray_vector_to_c_float_array(self.value)

                    glUniform1fv(self.location, <GLint>vector_len, <float*> f_array)
                    free(f_array)

                elif type_name == 'i':
                    i_array = ndarray_vector_to_c_int_array(self.value)

                    glUniform1iv(self.location, <GLint>vector_len, <int*> i_array)
                    free(i_array)

                else:
                    raise RuntimeError()


        else:
            # value is a matrix
            # glUniformMatrix4fv

            if type_name == 'i':
                raise NotImplementedError()

            fmatrix = self.value
            glUniformMatrix4fv(self.location, 1, GL_TRUE, &fmatrix[0, 0])

    def get_value(self):
        return self.value

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

        self.program = glCreateProgram()

        if not success:
            raise RuntimeError('glr_glfw_init failed with error {}'.format(status))

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
        if not shader.is_compiled():
            raise ValueError('Shader not compiled!')

        if shader.get_type() in self.shaders:
            print('Replacing existing shader!')

            #glDetachShader(self.program, shader.get_id())

            self.shaders[shader.get_type()] = shader

        glAttachShader(self.program, shader.get_id())
        print(self.get_program_log())

        if not self.is_linked():
            self.uniforms = dict()

        #     raise RuntimeError('not linked')
        # glDetachShader(self.program, shader.get_id())

    cpdef np.ndarray get_uniform(self, name):
        return self.uniforms[name].get_value()

    cpdef set_uniform(self, name, value):
        value = np.asarray(value)

        cdef bytes c_name = name.encode('UTF-8')

        location = glGetUniformLocation(self.program, c_name)

        if location < 0:
            raise RuntimeError('The is no uniform named {} inside the source.'.format(name))

        print("Got location: {}".format(location))

        uniform = GLUniform(name, location, value)

        print('Uploading {}...'.format(uniform))

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
        buffers = (GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1)

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
            print(self.get_program_log())
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
        printf('here render scene\n')

        glUseProgram(self.program)

        # now we have an instantiated glr_textured_mesh, we have to choose
        # some the OpenGL properties and set them. We decide that the vertices
        # should be bound to input 0 into the shader, while tcoords should be
        # input 1, and the float 3 vec is 2.

        self.mesh.vertices.attribute_pointer = 0
        self.mesh.tcoords.attribute_pointer = 1
        self.mesh.f3v_data.attribute_pointer = 2

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

    def print_active_uniforms(self):
        cdef int total = -1;
        glGetProgramiv(self.program, GL_ACTIVE_UNIFORMS, &total)

        cdef int name_len
        cdef GLint num
        cdef GLenum _type = GL_ZERO
        cdef char name[100];

        for t in range(total):
            glGetActiveUniform(self.program, <GLuint> t, sizeof(name)-1,
                &name_len, &num, &_type, name)

            name[name_len] = 0
            print("Uniform name: {}".format(name))

    def render_offscreen_rgb(self,
            np.ndarray[float, ndim=2, mode="c"] points not None,
            np.ndarray[float, ndim=2, mode="c"] f3v_data not None,
            np.ndarray[unsigned, ndim=2, mode="c"] trilist not None,
            np.ndarray[float, ndim=2, mode="c"] tcoords not None,
            np.ndarray[float, ndim=3, mode="c"] texture not None):

        self.mesh = glr_build_f3_f3_rgb_float_mesh(
            &points[0, 0], &f3v_data[0, 0], points.shape[0],
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

cdef class GLRasterizer(GLScene):
    def __init__(self, int width, int height):
        default_vertex_shader = VertexShader(DEFAULT_VERTEX_SHADER_SRC)
        default_fragment_shader = FragmentShader(DEFAULT_FRAGMENT_SHADER_SRC)

        self.attach_shaders((default_vertex_shader, default_fragment_shader))

        # Initialise camera/projection matrices

        orthog = np.require(np.eye(4), dtype=np.float32, requirements='C')

        self.set_model_matrix(orthog)
        self.set_view_matrix(orthog)
        self.set_projection_matrix(orthog)

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

