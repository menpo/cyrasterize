#include <stdlib.h>
#include <GL/glew.h>
#include <GLFW/glfw3.h>
#include "glrglfw.h"
#include "glr.h"
#include "print.h"


void glfw_error_callback(int error, const char* description)
{
    py_printf("GLFW ERROR (%d): %s\n", error, description);
}


glr_glfw_context glr_build_glfw_context_offscreen(int width, int height){
	glr_glfw_context context;
	context.title = "Offscreen Viewer";
    context.window_width=  width;
    context.window_height = height;
    context.offscreen = true;
    return context;
}


glr_STATUS _glr_glew_init(int verbose) {
	// Fire up GLEW
    // Flag is required for use with Core Profiles (which we need for OS X)
    // http://www.opengl.org/wiki/OpenGL_Loading_Library#GLEW
    glewExperimental = true;
	GLenum status = glewInit();
	if (status != GLEW_OK) {
	    py_printf("GLEW ERROR (%d): Failed to start! %s\n", status,
	              glewGetErrorString(status));
	    return GLR_GLEW_FAILED;
	}
	py_printf_v(verbose, "  - Using GLEW %s\n", glewGetString(GLEW_VERSION));
	if(GLEW_ARB_texture_buffer_object_rgb32) {
	   py_printf_v(verbose, "  - Float (X,Y,Z) rendering is supported\n");
	} else {
	   py_printf_v(verbose, "  - Float (X,Y,Z) rendering not supported\n");
	}

	py_printf_v(verbose, "  - OpenGL Version: %s\n",glGetString(GL_VERSION));
    // GLEW initialization sometimes sets the GL_INVALID_ENUM state even
    // though all is fine - swallow it here (and warn the user)
    // http://www.opengl.org/wiki/OpenGL_Loading_Library#GLEW
    GLenum err = glGetError();
    if (err == GL_INVALID_ENUM) {
        py_printf("GLEW Warning (%d): Swallowing GL_INVALID_ENUM error\n", err);
    }
    return GLR_SUCCESS;
}

glr_STATUS glr_glfw_init(glr_glfw_context* context, int verbose)
{
    // Set up the error callback so we get more useful information
    glfwSetErrorCallback(glfw_error_callback);
	py_printf_v(verbose, "GLFW: Initializing Context\n");
	// Fire up glfw
    if (!glfwInit())
        return GLR_GLFW_INIT_FAILED;
    glfwWindowHint(GLFW_VISIBLE, !context->offscreen);
    // ask for at least OpenGL 3.3 (might be able to
    // relax this in future to 3.2/3.1)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    // OS X will only give us such a profile if we ask for a forward
    // compatable core profile. Not that the forward copatibility is
    // a noop as we ask for 3.3, but unfortunately OS X needs it.
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_DEPTH_BITS, 16);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    context->window = glfwCreateWindow(
            context->window_width, context->window_height,
            context->title, NULL, NULL);
    if (!context->window)
    {
        glfwTerminate();
        return GLR_GLFW_WINDOW_FAILED;
    }
    glfwMakeContextCurrent(context->window);
    py_printf_v(verbose, "GLFW: Context Information\n");

    glr_STATUS status = _glr_glew_init(verbose);
    if (status != GLR_SUCCESS) {
        return status;
    }
    // trigger a viewport resize (seems to be required in 10.9)
	glViewport(0, 0, (GLsizei) context->window_width, 
                     (GLsizei) context->window_height);
    // set the global state to the sensible defaults
    glr_set_global_settings();
    return GLR_SUCCESS;
}


void glr_glfw_terminate(glr_glfw_context* context)
{
    // clear up our GLFW state
    glfwDestroyWindow(context->window);
    glfwTerminate();
}

