from libc.stdint cimport uint8_t
from libcpp cimport bool
from c_opengl cimport *

# we need to be able to hold onto a context reference
cdef extern from "./cpp/glrglfw.h":
    ctypedef struct glr_glfw_context:
        int window_width
        int window_height
        const char*title
        bool offscreen
        void* window

    ctypedef enum glr_STATUS:
        GLR_SUCCESS
        GLR_GLFW_INIT_FAILED
        GLR_GLFW_WINDOW_FAILED
        GLR_GLEW_FAILED

    cdef glr_glfw_context glr_build_glfw_context_offscreen(int width,
                                                           int height)
    cdef glr_STATUS glr_glfw_init(glr_glfw_context* context, int verbose)
    cdef void glr_glfw_terminate(glr_glfw_context* context)


# we need to be able to hold onto a scene reference
cdef extern from "./cpp/glr.h":

    ctypedef struct glr_texture:
        int internal_format
        int width
        int height
        int format
        int type
        void* data
        unsigned unit
        unsigned texture_ID
        unsigned sampler
        unsigned uniform
        GLuint id

    ctypedef struct glr_vectorset:
        void* vectors
        unsigned n_vectors
        unsigned n_dims
        unsigned size
        int datatype
        unsigned vbo
        unsigned attribute_pointer

    ctypedef struct glr_textured_mesh:
        glr_vectorset vertices
        glr_vectorset normals
        glr_vectorset f3v_data
        glr_vectorset tcoords
        glr_vectorset trilist
        glr_texture texture
        GLuint vao

    ctypedef struct glr_camera:
        float projectionMatrix [16]
        float viewMatrix [16]

    ctypedef struct glr_light:
        float position [4]

    ctypedef struct glr_scene:
        glr_textured_mesh mesh
        glr_camera camera
        glr_light light
        float modelMatrix [16]
        glr_glfw_context* context
        unsigned program
        unsigned fbo
        glr_texture fb_rgb_target
        glr_texture fb_f3v_target

    glr_textured_mesh glr_build_d4_f3_rgba_uint8_mesh(
            double* points, double* normals, float* f3v_data,
            size_t n_points, unsigned* trilist,
            size_t n_tris, float* tcoords, uint8_t* texture,
            size_t texture_width, size_t texture_height)

    glr_textured_mesh glr_build_f3_f3_rgb_float_mesh(
            float* points, float* normals, float* f3v_data,
            size_t n_points, unsigned* trilist,
            size_t n_tris, float* tcoords, float* texture,
            size_t texture_width, size_t texture_height)

    glr_texture glr_build_float_rgb_texture(float* t, size_t w, size_t h)
    glr_texture glr_build_float_rgba_texture(float* t, size_t w, size_t h)
    glr_texture glr_build_uint8_rgb_texture(uint8_t* t, size_t w, size_t h)
    glr_texture glr_build_uint8_rgba_texture(uint8_t* t, size_t w, size_t h)

    void glr_init_texture(glr_texture *texture)
    void glr_init_framebuffer(GLuint* fbo, glr_texture* texture, GLuint attachment)
    void glr_init_vao(glr_textured_mesh* mesh)
    void glr_register_draw_framebuffers(GLuint fbo, size_t n_attachments,
		 GLenum* attachments);
    void glr_get_framebuffer(glr_texture* texture)
    void glr_destroy_vbos_on_trianglar_mesh(glr_textured_mesh* mesh)



    glr_scene glr_build_scene()

    # utilities
    void glr_set_clear_color(float* clear_colour_4_vec)
    void glr_get_clear_color(float* clear_colour_4_vec)
    void glr_check_error()


cdef extern from "GLFW/glfw3.h":
    ctypedef struct GLFWwindow:
        pass
    void glfwSwapBuffers(GLFWwindow *window) nogil
    void glfwPollEvents() nogil

cdef extern from "stdlib.h":
    ctypedef unsigned long size_t
    void free(void *ptr) nogil
    void *realloc(void *ptr, size_t size) nogil
    void *malloc(size_t size) nogil
    void *calloc(size_t nmemb, size_t size) nogil


cdef extern from "string.h":
    void *memcpy(void *dest, void *src, size_t n) nogil
    void *memset(void *dest, int c, size_t len)

cdef extern from *:
    ctypedef char* const_char_ptr "const char*"