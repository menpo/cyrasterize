import os
import glob

"""
This short script finds all GLSL shader files in the
cyrasterize/shaders/
directory and creates a header of string literals.

For example,

cyrasterize/shaders/myshader.frag

generates:

const GLchar myshader_frag_str [] = "shader contents here"...

in the header file

cyrasterize/c/shaders.h

"""


header_file = 'shaders.h'
cyrasterize_dir = os.path.join(os.path.split(__file__)[0], 'cyrasterize')
print cyrasterize_dir
shaders_folder = os.path.join(cyrasterize_dir, 'shaders')
header_filepath = os.path.join(cyrasterize_dir, 'cpp', header_file)

print shaders_folder

class Shader:
    def __init__(self, path):
        self.path = path
        self.shader_type = os.path.splitext(path)[-1][1:]
        self.name = os.path.splitext(os.path.split(path)[-1])[0]
        with open(path) as f:
            self.lines = f.readlines()
        self._c_string = convert_to_c_literal(self.lines)

    @property
    def c_literal(self):
        return 'const GLchar {}_{}_str [] = {};\n'.format(
            self.name, self.shader_type, self._c_string)


def convert_to_c_literal(lines):
    lines_in_quotes = ["\"{}\\n\"\n".format(l.strip()) for l in lines]
    return reduce(lambda a, b: a + b, lines_in_quotes)


def rebuild_c_shaders():
    shader_paths = glob.glob(os.path.join(shaders_folder, '*'))
    shaders = [Shader(s) for s in shader_paths]
    lines = reduce(lambda a, b: a + b, [s.c_literal for s in shaders])
    with open(header_filepath, 'w') as f:
        f.write(lines)
