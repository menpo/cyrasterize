from libcpp cimport bool
from .c_opengl cimport *
from .c_opengl_debug cimport *
import logging as log


__all__ = ['VertexShader', 'FragmentShader']

cdef class ShaderSource:
    # Influenced by Kivy. If something goes wrong here it might worth
    # to have a look at Kivy's source code. I took some ideas from them
    # but reimplemented everything from scratch.
    #
    # https://github.com/kivy/kivy/blob/master/kivy/graphics/shader.pyx

    cpdef GLenum uid
    cpdef GLenum shader_type

    def __init__(self, str py_source, GLenum shader_type):
        self.shader_type = shader_type

        cdef GLint success = 0
        cdef GLuint error
        cdef GLenum uid
        # We have to copy the python str first to bytes in a
        # separate line before passing it to cython
        cdef bytes py_byte_source = py_source.encode('utf-8')

        cdef const GLchar* source = py_byte_source

        # create and compile
        self._compiled = False
        uid = glCreateShader(self.shader_type)
        glShaderSource(uid, 1, <GLchar**> &source, NULL)
        glCompileShader(uid)

        # ensure compilation is ok
        glGetShaderiv(uid, GL_COMPILE_STATUS, &success)
        self.uid = uid

        if success == GL_FALSE:
            error = glGetError()

            glDeleteShader(uid)

            raise RuntimeError('Shader: <%s> failed to compile (gl:%d)' % (
                str(self), error))

        log.info('Compiled a {} ({}) shader'.format(str(self), self.shader_type))
        self._compiled = True

    def __dealloc__(self):
        # if self.shader != -1:
        log.debug('TODO Maybe we have to deallocate the shader here?')

    cpdef bool is_compiled(self):
        return self._compiled

    cdef get_shader_log(self):
        cdef bytes py_msg
        cdef int info_length
        glGetShaderiv(self.uid, GL_INFO_LOG_LENGTH, &info_length)
        if info_length <= 0:
            return ""
        cdef char* msg = <char *>malloc(info_length * sizeof(char))
        if msg == NULL:
            return ""
        msg[0] = "\0"
        glGetShaderInfoLog(self.uid, info_length, NULL, msg)
        py_msg = msg
        free(msg)
        return py_msg

    def __hash__(self):
        return self.uid

    cpdef get_type(self):
        return self.shader_type

    cpdef get_id(self):
        return self.uid

    def __str__(self):
        return "{} [{}]".format(self.__class__.__name__, self.uid)

class VertexShader(ShaderSource):
    def __init__(self, src):
        super(VertexShader, self).__init__(src, GL_VERTEX_SHADER)

class FragmentShader(ShaderSource):
    def __init__(self, src):
        super(FragmentShader, self).__init__(src, GL_FRAGMENT_SHADER)

class GeometryShader(ShaderSource):
    def __init__(self, src):
        super(FragmentShader, self).__init__(src, GL_GEOMETRY_SHADER)