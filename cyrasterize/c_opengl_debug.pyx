# distutils: language = c++
import logging as log
cimport c_opengl as cgl

cdef extern from *:
    ctypedef char* const_char_ptr "const char*"

cdef extern from 'GL/glew.h':
    const GLubyte* gluErrorString(GLenum error);

class bcolors:
    YELLOW = '\x1b[33m'
    RED = '\x1b[31m'
    END = '\x1b[0m'

def printWarn(string, color=bcolors.YELLOW):
    log.debug(color + string + color)

cdef print_error():
    code = cgl.glGetError()
    cdef char* c_char = <char*> gluErrorString(code)
    cdef bytes pyString = c_char

    if code:
        log.error(" *** Error *** [{}] {}".format(pyString, code) + bcolors.RED)

cdef void   glActiveTexture (GLenum texture) with gil:
    printWarn("GL glActiveTexture( texture = " + str(texture) + ", )")
    cgl.glActiveTexture ( texture)
    print_error()

cdef void   glAttachShader (GLuint program, GLuint shader) with gil:
    printWarn("GL glAttachShader( program = " + str(program) + ", shader = " + str(shader) + ",)")
    cgl.glAttachShader ( program, shader)
    print_error()
    
cdef void   glBindAttribLocation (GLuint program, GLuint index,  GLchar* name) with gil:
    printWarn("GL glBindAttribLocation( program = " + str(program) + ", index = " + str(index) + ", name*=" + str(repr(hex(<long> name))) + ", )")
    cgl.glBindAttribLocation ( program, index, name)
    print_error()
    
cdef void   glBindBuffer (GLenum target, GLuint buffer) with gil:
    printWarn("GL glBindBuffer( target = " + str(target) + ", buffer = " + str(buffer) + ", )")
    cgl.glBindBuffer ( target, buffer)
    print_error()
    
cdef void   glBindFramebuffer (GLenum target, GLuint framebuffer) with gil:
    printWarn("GL glBindFramebuffer( target = " + str(target) + ", framebuffer = " + str(framebuffer) + ", )")
    cgl.glBindFramebuffer ( target, framebuffer)
    print_error()
    
cdef void   glBindRenderbuffer (GLenum target, GLuint renderbuffer) with gil:
    printWarn("GL glBindRenderbuffer( target = " + str(target) + ", renderbuffer = " + str(renderbuffer) + ", )")
    cgl.glBindRenderbuffer ( target, renderbuffer)
    print_error()
    
cdef void   glBindTexture (GLenum target, GLuint texture) with gil:
    printWarn("GL glBindTexture( target = " + str(target) + ", texture = " + str(texture) + ", )")
    cgl.glBindTexture ( target, texture)
    print_error()
    
cdef void   glBlendColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) with gil:
    printWarn("GL glBlendColor( red = " + str(red) + ", green = " + str(green) + ", blue = " + str(blue) + ", alpha = " + str(alpha) + ", )")
    cgl.glBlendColor ( red, green, blue, alpha)
    print_error()
    
cdef void   glBlendEquation (GLenum mode) with gil:
    printWarn("GL glBlendEquation( mode = " + str(mode) + ", )")
    cgl.glBlendEquation ( mode)
    print_error()
    
cdef void   glBlendEquationSeparate (GLenum modeRGB, GLenum modeAlpha) with gil:
    printWarn("GL glBlendEquationSeparate( modeRGB = " + str(modeRGB) + ", modeAlpha = " + str(modeAlpha) + ", )")
    cgl.glBlendEquationSeparate ( modeRGB, modeAlpha)
    print_error()
    
cdef void   glBlendFunc (GLenum sfactor, GLenum dfactor) with gil:
    printWarn("GL glBlendFunc( sfactor = " + str(sfactor) + ", dfactor = " + str(dfactor) + ", )")
    cgl.glBlendFunc ( sfactor, dfactor)
    print_error()
    
cdef void   glBlendFuncSeparate (GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha) with gil:
    printWarn("GL glBlendFuncSeparate( srcRGB = " + str(srcRGB) + ", dstRGB = " + str(dstRGB) + ", srcAlpha = " + str(srcAlpha) + ", dstAlpha = " + str(dstAlpha) + ", )")
    cgl.glBlendFuncSeparate ( srcRGB, dstRGB, srcAlpha, dstAlpha)
    print_error()
    
cdef void   glBufferData (GLenum target, GLsizeiptr size,  GLvoid* data, GLenum usage) with gil:
    printWarn("GL glBufferData( target = " + str(target) + ", size = " + str(size) + ", data*=" + str(repr(hex(<long> data))) + ", usage = " + str(usage) + ", )")
    cgl.glBufferData ( target, size, data, usage)
    print_error()
    
cdef void   glBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size,  GLvoid* data) with gil:
    printWarn("GL glBufferSubData( target = " + str(target) + ", offset = " + str(offset) + ", size = " + str(size) + ", data*=" + str(repr(hex(<long> data))) + ", )")
    cgl.glBufferSubData ( target, offset, size, data)
    print_error()
    
cdef GLenum glCheckFramebufferStatus (GLenum target) with gil:
    printWarn("GL glCheckFramebufferStatus( target = " + str(target) + ", )")
    print_error()

    cdef GLenum ret = cgl.glCheckFramebufferStatus (target)
    return ret


cdef void   glClear (GLbitfield mask) with gil:
    printWarn("GL glClear( mask = " + str(mask) + ", )")
    cgl.glClear ( mask)
    print_error()
    
cdef void   glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampf alpha) with gil:
    printWarn("GL glClearColor( red = " + str(red) + ", green = " + str(green) + ", blue = " + str(blue) + ", alpha = " + str(alpha) + ", )")
    cgl.glClearColor ( red, green, blue, alpha)
    print_error()
    
#crash on android platform
#cdef void   glClearDepthf (GLclampf depth) with gil:
#    printWarn("GL glClearDepthf( depth = " + str(depth) + ", )")
#    cgl.glClearDepthf ( depth)
#    print_error()
#    
cdef void   glClearStencil (GLint s) with gil:
    printWarn("GL glClearStencil( s = " + str(s) + ", )")
    cgl.glClearStencil ( s)
    print_error()
    
cdef void   glColorMask (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha) with gil:
    printWarn("GL glColorMask( red = " + str(red) + ", green = " + str(green) + ", blue = " + str(blue) + ", alpha = " + str(alpha) + ", )")
    cgl.glColorMask ( red, green, blue, alpha)
    print_error()
    
cdef void   glCompileShader (GLuint shader) with gil:
    printWarn("GL glCompileShader( shader = " + str(shader) + ", )")
    cgl.glCompileShader ( shader)
    print_error()
    
cdef void   glCompressedTexImage2D (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize,  GLvoid* data) with gil:
    printWarn("GL glCompressedTexImage2D( target = " + str(target) + ", level = " + str(level) + ", internalformat = " + str(internalformat) + ", width = " + str(width) + ", height = " + str(height) + ", border = " + str(border) + ", imageSize = " + str(imageSize) + ", data*=" + str(repr(hex(<long> data))) + ", )")
    cgl.glCompressedTexImage2D ( target, level, internalformat, width, height, border, imageSize, data)
    print_error()
    
cdef void   glCompressedTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize,  GLvoid* data) with gil:
    printWarn("GL glCompressedTexSubImage2D( target = " + str(target) + ", level = " + str(level) + ", xoffset = " + str(xoffset) + ", yoffset = " + str(yoffset) + ", width = " + str(width) + ", height = " + str(height) + ", format = " + str(format) + ", imageSize = " + str(imageSize) + ", data*=" + str(repr(hex(<long> data))) + ", )")
    cgl.glCompressedTexSubImage2D ( target, level, xoffset, yoffset, width, height, format, imageSize, data)
    print_error()
    
cdef void   glCopyTexImage2D (GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border) with gil:
    printWarn("GL glCopyTexImage2D( target = " + str(target) + ", level = " + str(level) + ", internalformat = " + str(internalformat) + ", x = " + str(x) + ", y = " + str(y) + ", width = " + str(width) + ", height = " + str(height) + ", border = " + str(border) + ", )")
    cgl.glCopyTexImage2D ( target, level, internalformat, x, y, width, height, border)
    print_error()
    
cdef void   glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height) with gil:
    printWarn("GL glCopyTexSubImage2D( target = " + str(target) + ", level = " + str(level) + ", xoffset = " + str(xoffset) + ", yoffset = " + str(yoffset) + ", x = " + str(x) + ", y = " + str(y) + ", width = " + str(width) + ", height = " + str(height) + ", )")
    cgl.glCopyTexSubImage2D ( target, level, xoffset, yoffset, x, y, width, height)
    print_error()
    
cdef GLuint glCreateProgram () with gil:
    printWarn("GL glCreateProgram( )")
    print_error()
    
    return cgl.glCreateProgram ()
cdef GLuint glCreateShader (GLenum type) with gil:
    printWarn("GL glCreateShader( type = " + str(type) + ", )")
    print_error()
    
    return cgl.glCreateShader ( type)
cdef void   glCullFace (GLenum mode) with gil:
    printWarn("GL glCullFace( mode = " + str(mode) + ", )")
    cgl.glCullFace ( mode)
    print_error()
    
cdef void   glDeleteBuffers (GLsizei n,  GLuint* buffers) with gil:
    printWarn("GL glDeleteBuffers( n = " + str(n) + ", buffers*=" + str(repr(hex(<long> buffers))) + ", )")
    cgl.glDeleteBuffers ( n, buffers)
    print_error()
    
cdef void   glDeleteFramebuffers (GLsizei n,  GLuint* framebuffers) with gil:
    printWarn("GL glDeleteFramebuffers( n = " + str(n) + ", framebuffers*=" + str(repr(hex(<long> framebuffers))) + ", )")
    cgl.glDeleteFramebuffers ( n, framebuffers)
    print_error()
    
cdef void   glDeleteProgram (GLuint program) with gil:
    printWarn("GL glDeleteProgram( program = " + str(program) + ", )")
    cgl.glDeleteProgram ( program)
    print_error()
    
cdef void   glDeleteRenderbuffers (GLsizei n,  GLuint* renderbuffers) with gil:
    printWarn("GL glDeleteRenderbuffers( n = " + str(n) + ", renderbuffers*=" + str(repr(hex(<long> renderbuffers))) + ", )")
    cgl.glDeleteRenderbuffers ( n, renderbuffers)
    print_error()
    
cdef void   glDeleteShader (GLuint shader) with gil:
    printWarn("GL glDeleteShader( shader = " + str(shader) + ", )")
    cgl.glDeleteShader ( shader)
    print_error()
    
cdef void   glDeleteTextures (GLsizei n,  GLuint* textures) with gil:
    printWarn("GL glDeleteTextures( n = " + str(n) + ", textures*=" + str(repr(hex(<long> textures))) + ", )")
    cgl.glDeleteTextures ( n, textures)
    print_error()
    
cdef void   glDepthFunc (GLenum func) with gil:
    printWarn("GL glDepthFunc( func = " + str(func) + ", )")
    cgl.glDepthFunc ( func)
    print_error()
    
cdef void   glDepthMask (GLboolean flag) with gil:
    printWarn("GL glDepthMask( flag = " + str(flag) + ", )")
    cgl.glDepthMask ( flag)
    print_error()

cdef void   glDetachShader (GLuint program, GLuint shader) with gil:
    printWarn("GL glDetachShader( program = " + str(program) + ", shader = " + str(shader) + ", )")
    cgl.glDetachShader ( program, shader)
    print_error()
    
cdef void   glDisable (GLenum cap) with gil:
    printWarn("GL glDisable( cap = " + str(cap) + ", )")
    cgl.glDisable ( cap)
    print_error()
    
cdef void   glDisableVertexAttribArray (GLuint index) with gil:
    printWarn("GL glDisableVertexAttribArray( index = " + str(index) + ", )")
    cgl.glDisableVertexAttribArray ( index)
    print_error()
    
cdef void   glDrawArrays (GLenum mode, GLint first, GLsizei count) with gil:
    printWarn("GL glDrawArrays( mode = " + str(mode) + ", first = " + str(first) + ", count = " + str(count) + ", )")
    cgl.glDrawArrays ( mode, first, count)
    print_error()
    
cdef void   glDrawElements (GLenum mode, GLsizei count, GLenum type,  GLvoid* indices) with gil:
    printWarn("GL glDrawElements( mode = " + str(mode) + ", count = " + str(count) + ", type = " + str(type) + ", indices*=" + str(repr(hex(<long> indices))) + ", )")
    cgl.glDrawElements ( mode, count, type, indices)
    print_error()
    
cdef void   glEnable (GLenum cap) with gil:
    printWarn("GL glEnable( cap = " + str(cap) + ", )")
    cgl.glEnable ( cap)
    print_error()
    
cdef void   glEnableVertexAttribArray (GLuint index) with gil:
    printWarn("GL glEnableVertexAttribArray( index = " + str(index) + ", )")
    cgl.glEnableVertexAttribArray ( index)
    print_error()
    
cdef void   glFinish () with gil:
    printWarn("GL glFinish( )")
    cgl.glFinish ()
    print_error()
    
cdef void   glFlush () with gil:
    printWarn("GL glFlush( )")
    cgl.glFlush ()
    print_error()
    
cdef void   glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer) with gil:
    printWarn("GL glFramebufferRenderbuffer( target = " + str(target) + ", attachment = " + str(attachment) + ", renderbuffertarget = " + str(renderbuffertarget) + ", renderbuffer = " + str(renderbuffer) + ", )")
    cgl.glFramebufferRenderbuffer ( target, attachment, renderbuffertarget, renderbuffer)
    print_error()
    
cdef void   glFramebufferTexture2D (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level) with gil:
    printWarn("GL glFramebufferTexture2D( target = " + str(target) + ", attachment = " + str(attachment) + ", textarget = " + str(textarget) + ", texture = " + str(texture) + ", level = " + str(level) + ", )")
    cgl.glFramebufferTexture2D ( target, attachment, textarget, texture, level)
    print_error()
    
cdef void   glFrontFace (GLenum mode) with gil:
    printWarn("GL glFrontFace( mode = " + str(mode) + ", )")
    cgl.glFrontFace ( mode)
    print_error()
    
cdef void   glGenBuffers (GLsizei n, GLuint* buffers) with gil:
    printWarn("GL glGenBuffers( n = " + str(n) + ", buffers*=" + str(repr(hex(<long> buffers))) + ", )")
    cgl.glGenBuffers ( n, buffers)
    print_error()
    
cdef void   glGenerateMipmap (GLenum target) with gil:
    printWarn("GL glGenerateMipmap( target = " + str(target) + ", )")
    cgl.glGenerateMipmap ( target)
    print_error()
    
cdef void   glGenFramebuffers (GLsizei n, GLuint* framebuffers) with gil:
    printWarn("GL glGenFramebuffers( n = " + str(n) + ", framebuffers*=" + str(repr(hex(<long> framebuffers))) + ", )")
    cgl.glGenFramebuffers ( n, framebuffers)
    print_error()
    
cdef void   glGenRenderbuffers (GLsizei n, GLuint* renderbuffers) with gil:
    printWarn("GL glGenRenderbuffers( n = " + str(n) + ", renderbuffers*=" + str(repr(hex(<long> renderbuffers))) + ", )")
    cgl.glGenRenderbuffers ( n, renderbuffers)
    print_error()
    
cdef void   glGenTextures (GLsizei n, GLuint* textures) with gil:
    printWarn("GL glGenTextures( n = " + str(n) + ", textures*=" + str(repr(hex(<long> textures))) + ", )")
    cgl.glGenTextures ( n, textures)
    print_error()
    
cdef void   glGetActiveAttrib (GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name) with gil:
    printWarn("GL glGetActiveAttrib( program = " + str(program) + ", index = " + str(index) + ", bufsize = " + str(bufsize) + ", length*=" + str(repr(hex(<long> length))) + ", size*=" + str(repr(hex(<long> size))) + ", type*=" + str(repr(hex(<long> type))) + ", name*=" + str(repr(hex(<long> name))) + ", )")
    cgl.glGetActiveAttrib ( program, index, bufsize, length, size, type, name)
    print_error()
    
cdef void   glGetActiveUniform (GLuint program, GLuint index, GLsizei bufsize, GLsizei* length, GLint* size, GLenum* type, GLchar* name) with gil:
    printWarn("GL glGetActiveUniform( program = " + str(program) + ", index = " + str(index) + ", bufsize = " + str(bufsize) + ", length*=" + str(repr(hex(<long> length))) + ", size*=" + str(repr(hex(<long> size))) + ", type*=" + str(repr(hex(<long> type))) + ", name*=" + str(repr(hex(<long> name))) + ", )")
    cgl.glGetActiveUniform ( program, index, bufsize, length, size, type, name)
    print_error()
    
cdef void   glGetAttachedShaders (GLuint program, GLsizei maxcount, GLsizei* count, GLuint* shaders) with gil:
    printWarn("GL glGetAttachedShaders( program = " + str(program) + ", maxcount = " + str(maxcount) + ", count*=" + str(repr(hex(<long> count))) + ", shaders*=" + str(repr(hex(<long> shaders))) + ", )")
    cgl.glGetAttachedShaders ( program, maxcount, count, shaders)
    print_error()
    
cdef int    glGetAttribLocation (GLuint program,  GLchar* name) with gil:
    printWarn("GL glGetAttribLocation( program = " + str(program) + ", name*=" + str(repr(hex(<long> name))) + ", )")
    print_error()
    
    return cgl.glGetAttribLocation ( program, name)
cdef void   glGetBooleanv (GLenum pname, GLboolean* params) with gil:
    printWarn("GL glGetBooleanv( pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetBooleanv ( pname, params)
    print_error()
    
cdef void   glGetBufferParameteriv (GLenum target, GLenum pname, GLint* params) with gil:
    printWarn("GL glGetBufferParameteriv( target = " + str(target) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetBufferParameteriv ( target, pname, params)
    print_error()
    
cdef GLenum glGetError () with gil:
    return cgl.glGetError ()

cdef void   glGetFloatv (GLenum pname, GLfloat* params) with gil:
    printWarn("GL glGetFloatv( pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetFloatv ( pname, params)
    print_error()
    
cdef void   glGetFramebufferAttachmentParameteriv (GLenum target, GLenum attachment, GLenum pname, GLint* params) with gil:
    printWarn("GL glGetFramebufferAttachmentParameteriv( target = " + str(target) + ", attachment = " + str(attachment) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetFramebufferAttachmentParameteriv ( target, attachment, pname, params)
    print_error()
    
cdef void   glGetIntegerv (GLenum pname, GLint* params) with gil:
    printWarn("GL glGetIntegerv( pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetIntegerv ( pname, params)
    print_error()
    
cdef void   glGetProgramiv (GLuint program, GLenum pname, GLint* params) with gil:
    printWarn("GL glGetProgramiv( program = " + str(program) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetProgramiv ( program, pname, params)
    print_error()
    
cdef void   glGetProgramInfoLog (GLuint program, GLsizei bufsize, GLsizei* length, GLchar* infolog) with gil:
    printWarn("GL glGetProgramInfoLog( program = " + str(program) + ", bufsize = " + str(bufsize) + ", length*=" + str(repr(hex(<long> length))) + ", infolog*=" + str(repr(hex(<long> infolog))) + ", )")
    cgl.glGetProgramInfoLog ( program, bufsize, length, infolog)
    print_error()
    
cdef void   glGetRenderbufferParameteriv (GLenum target, GLenum pname, GLint* params) with gil:
    printWarn("GL glGetRenderbufferParameteriv( target = " + str(target) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetRenderbufferParameteriv ( target, pname, params)
    print_error()
    
cdef void   glGetShaderiv (GLuint shader, GLenum pname, GLint* params) with gil:
    printWarn("GL glGetShaderiv( shader = " + str(shader) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetShaderiv ( shader, pname, params)
    print_error()
    
cdef void   glGetShaderInfoLog (GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* infolog) with gil:
    printWarn("GL glGetShaderInfoLog( shader = " + str(shader) + ", bufsize = " + str(bufsize) + ", length*=" + str(repr(hex(<long> length))) + ", infolog*=" + str(repr(hex(<long> infolog))) + ", )")
    cgl.glGetShaderInfoLog ( shader, bufsize, length, infolog)
    print_error()
    
# Skipping generation of: "#cdef void   glGetShaderPrecisionFormat (cgl.GLenum shadertype, cgl.GLenum precisiontype, cgl.GLint* range, cgl.GLint* precision)"
cdef void   glGetShaderSource (GLuint shader, GLsizei bufsize, GLsizei* length, GLchar* source) with gil:
    printWarn("GL glGetShaderSource( shader = " + str(shader) + ", bufsize = " + str(bufsize) + ", length*=" + str(repr(hex(<long> length))) + ", source*=" + str(repr(hex(<long> source))) + ", )")
    cgl.glGetShaderSource ( shader, bufsize, length, source)
    print_error()
    
cdef   GLubyte*  glGetString (GLenum name) with gil:
    printWarn("GL glGetString( name = " + str(name) + ", )")
    return <GLubyte*><char*>cgl.glGetString ( name)
cdef void   glGetTexParameterfv (GLenum target, GLenum pname, GLfloat* params) with gil:
    printWarn("GL glGetTexParameterfv( target = " + str(target) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetTexParameterfv ( target, pname, params)
    print_error()
    
cdef void   glGetTexParameteriv (GLenum target, GLenum pname, GLint* params) with gil:
    printWarn("GL glGetTexParameteriv( target = " + str(target) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetTexParameteriv ( target, pname, params)
    print_error()
    
cdef void   glGetUniformfv (GLuint program, GLint location, GLfloat* params) with gil:
    printWarn("GL glGetUniformfv( program = " + str(program) + ", location = " + str(location) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetUniformfv ( program, location, params)
    print_error()
    
cdef void   glGetUniformiv (GLuint program, GLint location, GLint* params) with gil:
    printWarn("GL glGetUniformiv( program = " + str(program) + ", location = " + str(location) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetUniformiv ( program, location, params)
    print_error()
    
cdef int    glGetUniformLocation (GLuint program,  GLchar* name) with gil:
    printWarn("GL glGetUniformLocation( program = " + str(program) + ", name*=" + str(repr(hex(<long> name))) + ", )")
    print_error()
    
    return cgl.glGetUniformLocation ( program, name)
cdef void   glGetVertexAttribfv (GLuint index, GLenum pname, GLfloat* params) with gil:
    printWarn("GL glGetVertexAttribfv( index = " + str(index) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetVertexAttribfv ( index, pname, params)
    print_error()
    
cdef void   glGetVertexAttribiv (GLuint index, GLenum pname, GLint* params) with gil:
    printWarn("GL glGetVertexAttribiv( index = " + str(index) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glGetVertexAttribiv ( index, pname, params)
    print_error()
    
cdef void   glGetVertexAttribPointerv (GLuint index, GLenum pname, GLvoid** pointer) with gil:
    printWarn("GL glGetVertexAttribPointerv( index = " + str(index) + ", pname = " + str(pname) + ", pointer**=" + str(repr(hex(<long> pointer))) + ", )")
    cgl.glGetVertexAttribPointerv ( index, pname, pointer)
    print_error()
    
cdef void   glHint (GLenum target, GLenum mode) with gil:
    printWarn("GL glHint( target = " + str(target) + ", mode = " + str(mode) + ", )")
    cgl.glHint ( target, mode)
    print_error()
    
cdef GLboolean  glIsBuffer (GLuint buffer) with gil:
    printWarn("GL glIsBuffer( buffer = " + str(buffer) + ", )")
    print_error()
    
    return cgl.glIsBuffer ( buffer)
cdef GLboolean  glIsEnabled (GLenum cap) with gil:
    printWarn("GL glIsEnabled( cap = " + str(cap) + ", )")
    print_error()
    
    return cgl.glIsEnabled ( cap)
cdef GLboolean  glIsFramebuffer (GLuint framebuffer) with gil:
    printWarn("GL glIsFramebuffer( framebuffer = " + str(framebuffer) + ", )")
    print_error()
    
    return cgl.glIsFramebuffer ( framebuffer)
cdef GLboolean  glIsProgram (GLuint program) with gil:
    printWarn("GL glIsProgram( program = " + str(program) + ", )")
    print_error()
    
    return cgl.glIsProgram ( program)
cdef GLboolean  glIsRenderbuffer (GLuint renderbuffer) with gil:
    printWarn("GL glIsRenderbuffer( renderbuffer = " + str(renderbuffer) + ", )")
    print_error()
    
    return cgl.glIsRenderbuffer ( renderbuffer)
cdef GLboolean  glIsShader (GLuint shader) with gil:
    printWarn("GL glIsShader( shader = " + str(shader) + ", )")
    print_error()
    
    return cgl.glIsShader ( shader)
cdef GLboolean  glIsTexture (GLuint texture) with gil:
    printWarn("GL glIsTexture( texture = " + str(texture) + ", )")
    print_error()
    
    return cgl.glIsTexture ( texture)
cdef void  glLineWidth (GLfloat width) with gil:
    printWarn("GL glLineWidth( width = " + str(width) + ", )")
    cgl.glLineWidth ( width)
    print_error()
    
cdef void  glLinkProgram (GLuint program) with gil:
    printWarn("GL glLinkProgram( program = " + str(program) + ", )")
    cgl.glLinkProgram ( program)
    print_error()
    
cdef void  glPixelStorei (GLenum pname, GLint param) with gil:
    printWarn("GL glPixelStorei( pname = " + str(pname) + ", param = " + str(param) + ", )")
    cgl.glPixelStorei ( pname, param)
    print_error()
    
cdef void  glPolygonOffset (GLfloat factor, GLfloat units) with gil:
    printWarn("GL glPolygonOffset( factor = " + str(factor) + ", units = " + str(units) + ", )")
    cgl.glPolygonOffset ( factor, units)
    print_error()
    
cdef void  glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLvoid* pixels) with gil:
    printWarn("GL glReadPixels( x = " + str(x) + ", y = " + str(y) + ", width = " + str(width) + ", height = " + str(height) + ", format = " + str(format) + ", type = " + str(type) + ", pixels*=" + str(repr(hex(<long> pixels))) + ", )")
    cgl.glReadPixels ( x, y, width, height, format, type, pixels)
    print_error()
    
# Skipping generation of: "#cdef void  glReleaseShaderCompiler ()"
cdef void  glRenderbufferStorage (GLenum target, GLenum internalformat, GLsizei width, GLsizei height) with gil:
    printWarn("GL glRenderbufferStorage( target = " + str(target) + ", internalformat = " + str(internalformat) + ", width = " + str(width) + ", height = " + str(height) + ", )")
    cgl.glRenderbufferStorage ( target, internalformat, width, height)
    print_error()
    
cdef void  glSampleCoverage (GLclampf value, GLboolean invert) with gil:
    printWarn("GL glSampleCoverage( value = " + str(value) + ", invert = " + str(invert) + ", )")
    cgl.glSampleCoverage ( value, invert)
    print_error()
    
cdef void  glScissor (GLint x, GLint y, GLsizei width, GLsizei height) with gil:
    printWarn("GL glScissor( x = " + str(x) + ", y = " + str(y) + ", width = " + str(width) + ", height = " + str(height) + ", )")
    cgl.glScissor ( x, y, width, height)
    print_error()
    
# Skipping generation of: "#cdef void  glShaderBinary (cgl.GLsizei n,  cgl.GLuint* shaders, cgl.GLenum binaryformat,  cgl.GLvoid* binary, cgl.GLsizei length)"
cdef void  glShaderSource (GLuint shader, GLsizei count,  GLchar** string,  GLint* length) with gil:
    printWarn("GL glShaderSource( shader = " + str(shader) + ", count = " + str(count) + ", string**=" + str(repr(hex(<long> string))) + ", length*=" + str(repr(hex(<long> length))) + ", )")
    cgl.glShaderSource ( shader, count, <const_char_ptr*>string, length)
    ret = glGetError()
    if ret: log.error("ERR %d / %x" % (ret, ret))
cdef void  glStencilFunc (GLenum func, GLint ref, GLuint mask) with gil:
    printWarn("GL glStencilFunc( func = " + str(func) + ", ref = " + str(ref) + ", mask = " + str(mask) + ", )")
    cgl.glStencilFunc ( func, ref, mask)
    print_error()
    
cdef void  glStencilFuncSeparate (GLenum face, GLenum func, GLint ref, GLuint mask) with gil:
    printWarn("GL glStencilFuncSeparate( face = " + str(face) + ", func = " + str(func) + ", ref = " + str(ref) + ", mask = " + str(mask) + ", )")
    cgl.glStencilFuncSeparate ( face, func, ref, mask)
    print_error()
    
cdef void  glStencilMask (GLuint mask) with gil:
    printWarn("GL glStencilMask( mask = " + str(mask) + ", )")
    cgl.glStencilMask ( mask)
    print_error()
    
cdef void  glStencilMaskSeparate (GLenum face, GLuint mask) with gil:
    printWarn("GL glStencilMaskSeparate( face = " + str(face) + ", mask = " + str(mask) + ", )")
    cgl.glStencilMaskSeparate ( face, mask)
    print_error()
    
cdef void  glStencilOp (GLenum fail, GLenum zfail, GLenum zpass) with gil:
    printWarn("GL glStencilOp( fail = " + str(fail) + ", zfail = " + str(zfail) + ", zpass = " + str(zpass) + ", )")
    cgl.glStencilOp ( fail, zfail, zpass)
    print_error()
    
cdef void  glStencilOpSeparate (GLenum face, GLenum fail, GLenum zfail, GLenum zpass) with gil:
    printWarn("GL glStencilOpSeparate( face = " + str(face) + ", fail = " + str(fail) + ", zfail = " + str(zfail) + ", zpass = " + str(zpass) + ", )")
    cgl.glStencilOpSeparate ( face, fail, zfail, zpass)
    print_error()
    
cdef void  glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type,  GLvoid* pixels) with gil:
    printWarn("GL glTexImage2D( target = " + str(target) + ", level = " + str(level) + ", internalformat = " + str(internalformat) + ", width = " + str(width) + ", height = " + str(height) + ", border = " + str(border) + ", format = " + str(format) + ", type = " + str(type) + ", pixels*=" + str(repr(hex(<long> pixels))) + ", )")
    cgl.glTexImage2D ( target, level, internalformat, width, height, border, format, type, pixels)
    print_error()
    
cdef void  glTexParameterf (GLenum target, GLenum pname, GLfloat param) with gil:
    printWarn("GL glTexParameterf( target = " + str(target) + ", pname = " + str(pname) + ", param = " + str(param) + ", )")
    cgl.glTexParameterf ( target, pname, param)
    print_error()
    
cdef void  glTexParameterfv (GLenum target, GLenum pname,  GLfloat* params) with gil:
    printWarn("GL glTexParameterfv( target = " + str(target) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glTexParameterfv ( target, pname, params)
    print_error()
    
cdef void  glTexParameteri (GLenum target, GLenum pname, GLint param) with gil:
    printWarn("GL glTexParameteri( target = " + str(target) + ", pname = " + str(pname) + ", param = " + str(param) + ", )")
    cgl.glTexParameteri ( target, pname, param)
    print_error()
    
cdef void  glTexParameteriv (GLenum target, GLenum pname,  GLint* params) with gil:
    printWarn("GL glTexParameteriv( target = " + str(target) + ", pname = " + str(pname) + ", params*=" + str(repr(hex(<long> params))) + ", )")
    cgl.glTexParameteriv ( target, pname, params)
    print_error()
    
cdef void  glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type,  GLvoid* pixels) with gil:
    printWarn("GL glTexSubImage2D( target = " + str(target) + ", level = " + str(level) + ", xoffset = " + str(xoffset) + ", yoffset = " + str(yoffset) + ", width = " + str(width) + ", height = " + str(height) + ", format = " + str(format) + ", type = " + str(type) + ", pixels*=" + str(repr(hex(<long> pixels))) + ", )")
    cgl.glTexSubImage2D ( target, level, xoffset, yoffset, width, height, format, type, pixels)
    print_error()
    
cdef void  glUniform1f (GLint location, GLfloat x) with gil:
    printWarn("GL glUniform1f( location = " + str(location) + ", x = " + str(x) + ", )")
    cgl.glUniform1f ( location, x)
    print_error()
    
cdef void  glUniform1fv (GLint location, GLsizei count,  GLfloat* v) with gil:
    printWarn("GL glUniform1fv( location = " + str(location) + ", count = " + str(count) + ", v*=" + str(repr(hex(<long> v))) + ", )")
    cgl.glUniform1fv ( location, count, v)
    print_error()
    
cdef void  glUniform1i (GLint location, GLint x) with gil:
    printWarn("GL glUniform1i( location = " + str(location) + ", x = " + str(x) + ", )")
    cgl.glUniform1i ( location, x)
    print_error()
    
cdef void  glUniform1iv (GLint location, GLsizei count,  GLint* v) with gil:
    printWarn("GL glUniform1iv( location = " + str(location) + ", count = " + str(count) + ", v*=" + str(repr(hex(<long> v))) + ", )")
    cgl.glUniform1iv ( location, count, v)
    print_error()
    
cdef void  glUniform2f (GLint location, GLfloat x, GLfloat y) with gil:
    printWarn("GL glUniform2f( location = " + str(location) + ", x = " + str(x) + ", y = " + str(y) + ", )")
    cgl.glUniform2f ( location, x, y)
    print_error()
    
cdef void  glUniform2fv (GLint location, GLsizei count,  GLfloat* v) with gil:
    printWarn("GL glUniform2fv( location = " + str(location) + ", count = " + str(count) + ", v*=" + str(repr(hex(<long> v))) + ", )")
    cgl.glUniform2fv ( location, count, v)
    print_error()
    
cdef void  glUniform2i (GLint location, GLint x, GLint y) with gil:
    printWarn("GL glUniform2i( location = " + str(location) + ", x = " + str(x) + ", y = " + str(y) + ", )")
    cgl.glUniform2i ( location, x, y)
    print_error()
    
cdef void  glUniform2iv (GLint location, GLsizei count,  GLint* v) with gil:
    printWarn("GL glUniform2iv( location = " + str(location) + ", count = " + str(count) + ", v*=" + str(repr(hex(<long> v))) + ", )")
    cgl.glUniform2iv ( location, count, v)
    print_error()
    
cdef void  glUniform3f (GLint location, GLfloat x, GLfloat y, GLfloat z) with gil:
    printWarn("GL glUniform3f( location = " + str(location) + ", x = " + str(x) + ", y = " + str(y) + ", z = " + str(z) + ", )")
    cgl.glUniform3f ( location, x, y, z)
    print_error()
    
cdef void  glUniform3fv (GLint location, GLsizei count,  GLfloat* v) with gil:
    printWarn("GL glUniform3fv( location = " + str(location) + ", count = " + str(count) + ", v*=" + str(repr(hex(<long> v))) + ", )")
    cgl.glUniform3fv ( location, count, v)
    print_error()
    
cdef void  glUniform3i (GLint location, GLint x, GLint y, GLint z) with gil:
    printWarn("GL glUniform3i( location = " + str(location) + ", x = " + str(x) + ", y = " + str(y) + ", z = " + str(z) + ", )")
    cgl.glUniform3i ( location, x, y, z)
    print_error()
    
cdef void  glUniform3iv (GLint location, GLsizei count,  GLint* v) with gil:
    printWarn("GL glUniform3iv( location = " + str(location) + ", count = " + str(count) + ", v*=" + str(repr(hex(<long> v))) + ", )")
    cgl.glUniform3iv ( location, count, v)
    print_error()
    
cdef void  glUniform4f (GLint location, GLfloat x, GLfloat y, GLfloat z, GLfloat w) with gil:
    printWarn("GL glUniform4f( location = " + str(location) + ", x = " + str(x) + ", y = " + str(y) + ", z = " + str(z) + ", w = " + str(w) + ", )")
    cgl.glUniform4f ( location, x, y, z, w)
    print_error()
    
cdef void  glUniform4fv (GLint location, GLsizei count,  GLfloat* v) with gil:
    printWarn("GL glUniform4fv( location = " + str(location) + ", count = " + str(count) + ", v*=" + str(repr(hex(<long> v))) + ", )")
    cgl.glUniform4fv ( location, count, v)
    print_error()
    
cdef void  glUniform4i (GLint location, GLint x, GLint y, GLint z, GLint w) with gil:
    printWarn("GL glUniform4i( location = " + str(location) + ", x = " + str(x) + ", y = " + str(y) + ", z = " + str(z) + ", w = " + str(w) + ", )")
    cgl.glUniform4i ( location, x, y, z, w)
    print_error()
    
cdef void  glUniform4iv (GLint location, GLsizei count,  GLint* v) with gil:
    printWarn("GL glUniform4iv( location = " + str(location) + ", count = " + str(count) + ", v*=" + str(repr(hex(<long> v))) + ", )")
    cgl.glUniform4iv ( location, count, v)
    print_error()
    
cdef void  glUniformMatrix2fv (GLint location, GLsizei count, GLboolean transpose,  GLfloat* value) with gil:
    printWarn("GL glUniformMatrix2fv( location = " + str(location) + ", count = " + str(count) + ", transpose = " + str(transpose) + ", value*=" + str(repr(hex(<long> value))) + ", )")
    cgl.glUniformMatrix2fv ( location, count, transpose, value)
    print_error()
    
cdef void  glUniformMatrix3fv (GLint location, GLsizei count, GLboolean transpose,  GLfloat* value) with gil:
    printWarn("GL glUniformMatrix3fv( location = " + str(location) + ", count = " + str(count) + ", transpose = " + str(transpose) + ", value*=" + str(repr(hex(<long> value))) + ", )")
    cgl.glUniformMatrix3fv ( location, count, transpose, value)
    print_error()
    
cdef void  glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose,  GLfloat* value) with gil:
    printWarn("GL glUniformMatrix4fv( location = " + str(location) + ", count = " + str(count) + ", transpose = " + str(transpose) + ", value*=" + str(repr(hex(<long> value))) + ", )")
    cgl.glUniformMatrix4fv ( location, count, transpose, value)
    print_error()
    
cdef void  glUseProgram (GLuint program) with gil:
    printWarn("GL glUseProgram( program = " + str(program) + ", )")
    cgl.glUseProgram ( program)

    print_error()

cdef void  glBindVertexArray (GLuint program) with gil:
    printWarn("GL glBindVertexArray( vio = " + str(program) + ", )")
    cgl.glBindVertexArray ( program)

    log.debug("After glBindVertexArray( program = " + str(program) + ", )")

    print_error()

    
cdef void  glValidateProgram (GLuint program) with gil:
    printWarn("GL glValidateProgram( program = " + str(program) + ", )")
    cgl.glValidateProgram ( program)
    print_error()
    
cdef void  glVertexAttrib1f (GLuint indx, GLfloat x) with gil:
    printWarn("GL glVertexAttrib1f( indx = " + str(indx) + ", x = " + str(x) + ", )")
    cgl.glVertexAttrib1f ( indx, x)
    print_error()
    
cdef void  glVertexAttrib1fv (GLuint indx,  GLfloat* values) with gil:
    printWarn("GL glVertexAttrib1fv( indx = " + str(indx) + ", values*=" + str(repr(hex(<long> values))) + ", )")
    cgl.glVertexAttrib1fv ( indx, values)
    print_error()
    
cdef void  glVertexAttrib2f (GLuint indx, GLfloat x, GLfloat y) with gil:
    printWarn("GL glVertexAttrib2f( indx = " + str(indx) + ", x = " + str(x) + ", y = " + str(y) + ", )")
    cgl.glVertexAttrib2f ( indx, x, y)
    print_error()
    
cdef void  glVertexAttrib2fv (GLuint indx,  GLfloat* values) with gil:
    printWarn("GL glVertexAttrib2fv( indx = " + str(indx) + ", values*=" + str(repr(hex(<long> values))) + ", )")
    cgl.glVertexAttrib2fv ( indx, values)
    print_error()
    
cdef void  glVertexAttrib3f (GLuint indx, GLfloat x, GLfloat y, GLfloat z) with gil:
    printWarn("GL glVertexAttrib3f( indx = " + str(indx) + ", x = " + str(x) + ", y = " + str(y) + ", z = " + str(z) + ", )")
    cgl.glVertexAttrib3f ( indx, x, y, z)
    print_error()
    
cdef void  glVertexAttrib3fv (GLuint indx,  GLfloat* values) with gil:
    printWarn("GL glVertexAttrib3fv( indx = " + str(indx) + ", values*=" + str(repr(hex(<long> values))) + ", )")
    cgl.glVertexAttrib3fv ( indx, values)
    print_error()
    
cdef void  glVertexAttrib4f (GLuint indx, GLfloat x, GLfloat y, GLfloat z, GLfloat w) with gil:
    printWarn("GL glVertexAttrib4f( indx = " + str(indx) + ", x = " + str(x) + ", y = " + str(y) + ", z = " + str(z) + ", w = " + str(w) + ", )")
    cgl.glVertexAttrib4f ( indx, x, y, z, w)
    print_error()
    
cdef void  glVertexAttrib4fv (GLuint indx,  GLfloat* values) with gil:
    printWarn("GL glVertexAttrib4fv( indx = " + str(indx) + ", values*=" + str(repr(hex(<long> values))) + ", )")
    cgl.glVertexAttrib4fv ( indx, values)
    print_error()
    
cdef void  glVertexAttribPointer (GLuint indx, GLint size, GLenum type, GLboolean normalized, GLsizei stride,  GLvoid* ptr) with gil:
    printWarn("GL glVertexAttribPointer( indx = " + str(indx) + ", size = " + str(size) + ", type = " + str(type) + ", normalized = " + str(normalized) + ", stride = " + str(stride) + ", ptr*=" + str(repr(hex(<long> ptr))) + ", )")
    cgl.glVertexAttribPointer ( indx, size, type, normalized, stride, ptr)
    print_error()
    
cdef void  glViewport (GLint x, GLint y, GLsizei width, GLsizei height) with gil:
    printWarn("GL glViewport( x = " + str(x) + ", y = " + str(y) + ", width = " + str(width) + ", height = " + str(height) + ", )")
    cgl.glViewport ( x, y, width, height)
    print_error()
    