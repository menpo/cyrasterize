#pragma once

#include "GL/glew.h"
#if defined(__WIN32__) && !defined(__CYGWIN__)
#  if (defined(_MSC_VER) || defined(__MINGW32__)) && defined(BUILD_GL32) /* tag specify we're building mesa as a DLL */
#    define GLAPI __declspec(dllexport)
#  elif (defined(_MSC_VER) || defined(__MINGW32__)) && defined(_DLL) /* tag specifying we're building for DLL runtime support */
#    define GLAPI __declspec(dllimport)
#  else /* for use with static link lib build of Win32 edition only */
#    define GLAPI extern
#  endif /* _STATIC_MESA support */
#  if defined(__MINGW32__) && defined(GL_NO_STDCALL) || defined(UNDER_CE)  /* The generated DLLs by MingW with STDCALL are not compatible with the ones done by Microsoft's compilers */
#    define GLAPIENTRY 
#  else
#    define GLAPIENTRY __stdcall
#  endif
#elif defined(__CYGWIN__) && defined(USE_OPENGL32) /* use native windows opengl32 */
#  define GLAPI extern
#  define GLAPIENTRY __stdcall
#elif (defined(__GNUC__) && __GNUC__ >= 4) || (defined(__SUNPRO_C) && (__SUNPRO_C >= 0x590))
#  define GLAPI __attribute__((visibility("default")))
#  define GLAPIENTRY
#endif /* WIN32 && !CYGWIN */

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
