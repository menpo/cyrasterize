#pragma once

#include "GL/glew.h"
#ifndef GLAPI
#define GLAPI extern
#endif
#include "GL/osmesa.h"


typedef struct {
    int window_width;
	int window_height;
	void* frame_buffer;
    OSMesaContext window;
} glr_glfw_context;

typedef enum {
    GLR_SUCCESS,
    GLR_GLFW_INIT_FAILED,
    GLR_GLFW_WINDOW_FAILED,
    GLR_GLEW_FAILED,
}  glr_STATUS;

glr_glfw_context glr_build_glfw_context_offscreen(int width, int height);

glr_STATUS glr_glfw_init(glr_glfw_context* context);

void glr_glfw_terminate(glr_glfw_context* context);