#include <stdio.h>
#include <stdlib.h>
//#include <stdexcept>
#include "glrglfw.h"
#include "glr.h"

glr_glfw_context glr_build_glfw_context_offscreen(int width, int height){
	glr_glfw_context context;
    context.window_width = width;
    context.window_height = height;
    context.frame_buffer = malloc(width * height * 4 * sizeof(GLubyte));
//    if (context->frame_buffer == NULL) {
//        throw std::runtime_error("Failed to create framebuffer");
//    }
    return context;
}

glr_STATUS _glr_glew_init(void) {
	// Fire up GLEW
    // Flag is required for use with Core Profiles (which we need for OS X)
    // http://www.opengl.org/wiki/OpenGL_Loading_Library#GLEW
    glewExperimental = true;
	GLenum status = glewInit();
	if (status != GLEW_OK) {
	    fprintf(stderr, "GLEW Failed to start! Error: %s\n",
			   glewGetErrorString(status));
	    return GLR_GLEW_FAILED;
	}
	fprintf(stdout, "  - Using GLEW %s\n", glewGetString(GLEW_VERSION));
	if(GLEW_ARB_texture_buffer_object_rgb32)
	   fprintf(stdout, "  - Float (X,Y,Z) rendering is supported\n");
	else
	   fprintf(stdout, "  - Float (X,Y,Z) rendering not supported\n");

	fprintf(stdout,"  - OpenGL Version: %s\n",glGetString(GL_VERSION));
    // GLEW initialization sometimes sets the GL_INVALID_ENUM state even
    // though all is fine - swallow it here (and warn the user)
    // http://www.opengl.org/wiki/OpenGL_Loading_Library#GLEW
    GLenum err = glGetError();
    if (err == GL_INVALID_ENUM)
        fprintf(stderr,"swallowing GL_INVALID_ENUM error\n");
    return GLR_SUCCESS;
}

glr_STATUS glr_glfw_init(glr_glfw_context* context)
{
	printf("glr_glfw_init(...)\n");
	// Fire up osmesa
	// format, depthBits, stencilBits, accumBits, sharelist
    int attriblist[] = {OSMESA_PROFILE,               OSMESA_CORE_PROFILE,
                        OSMESA_CONTEXT_MAJOR_VERSION, 3,
                        OSMESA_CONTEXT_MINOR_VERSION, 3,
                        OSMESA_DEPTH_BITS,            16,
                        OSMESA_STENCIL_BITS,          8,
                        OSMESA_FORMAT,                OSMESA_RGBA,
                        0};
    context->window = OSMesaCreateContextAttribs(attriblist, NULL);

    if (!context->window)
    {
        glr_glfw_terminate(context);
        printf("Windows creation failed\n");
        return GLR_GLFW_WINDOW_FAILED;
    }
    if (OSMesaMakeCurrent(context->window, context->frame_buffer, GL_UNSIGNED_BYTE,
                          context->window_width, context->window_height) != GL_TRUE) {
        glr_glfw_terminate(context);
        printf("Make current failed\n");
        return GLR_GLFW_WINDOW_FAILED;
    }
    printf("Have context.\n");
    glr_STATUS status = _glr_glew_init();
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
    OSMesaDestroyContext(context->window);
    free(context->frame_buffer);
}

