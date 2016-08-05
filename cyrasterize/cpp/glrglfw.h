#pragma once

#include <GL/glew.h>
#include <GLFW/glfw3.h>

typedef struct {
    int window_width;
	int window_height;
	const char *title;
	bool offscreen;
    GLFWwindow* window;
} glr_glfw_context;

typedef enum {
    GLR_SUCCESS,
    GLR_GLFW_INIT_FAILED,
    GLR_GLFW_WINDOW_FAILED,
    GLR_GLEW_FAILED,
}  glr_STATUS;

glr_glfw_context glr_build_glfw_context_offscreen(int width, int height);
glr_STATUS glr_glfw_init(glr_glfw_context* context, int verbose);

void glr_glfw_terminate(glr_glfw_context* context);
void glfw_error_callback(int error, const char* description);