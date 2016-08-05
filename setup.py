from Cython.Build import cythonize
from functools import reduce
from glob import glob
from os import path
from setuptools import setup, find_packages, Extension
import numpy as np
import os
import shutil
import sys
import versioneer

# Declare the modules to by cythonised
sources = [
    "cyrasterize.glrasterizer",
    "cyrasterize.c_opengl_debug",
    "cyrasterize.shader"
]


# files to compile from glrasterizer
glrasterizer_sources = ["glr.cpp", "glrglfw.cpp"]
external_sources = [path.join(".", "cyrasterize", "cpp", s) for s in
                    glrasterizer_sources]


# kwargs to be provided to distutils
ext_kwargs = {
    'language': 'c++'
}

package_data_globs = ['*.pyx', '*.pxd', 'cpp/*.h', 'shaders/*.vert',
                      'shaders/*.frag']

# unfortunately, linking requirements differ on OS X vs Linux vs Windows
# On Windows we essentially just copy the DLLs into the path so that
# compiling/run time linking works.


def localpath(*args):
    return os.path.abspath(reduce(os.path.join, (os.path.dirname(__file__),) + args))


if sys.platform.startswith('win'):
    CONDA_GLEW_DIR = os.environ['CONDA_GLEW_DIR']
    CONDA_GLFW_DIR = os.environ['CONDA_GLFW_DIR']
    if CONDA_GLEW_DIR is not None:
        ext_kwargs['include_dirs'] = [os.path.join(CONDA_GLEW_DIR, 'include'),
                                      os.path.join(CONDA_GLFW_DIR, 'include')]
        ext_kwargs['library_dirs'] = [os.path.join(CONDA_GLEW_DIR, 'lib'),
                                      os.path.join(CONDA_GLFW_DIR, 'lib')]
        ext_kwargs['libraries'] = ['glew32', 'glfw3dll', 'OpenGL32', 'glu32']
        dlls = glob(os.path.join(CONDA_GLEW_DIR, 'lib', 'glew*.dll'))
        dlls += glob(os.path.join(CONDA_GLFW_DIR, 'lib', 'glfw3*.dll'))
        for d in dlls:
            basename = os.path.basename(d)
            shutil.copy(d, localpath('cyrasterize', basename))
    # look for .dlls on the package_data
    package_data_globs.append('*.dll')
elif sys.platform.startswith('linux'):
    ext_kwargs['libraries'] = ['m', 'GLEW', 'GL', 'GLU', 'glfw']
    ext_kwargs['include_dirs'] = [np.get_include()]
    ext_kwargs['extra_compile_args'] = ['-Wno-unused-function']

elif sys.platform == 'darwin':
    ext_kwargs['libraries'] = ['m', 'GLEW', 'glfw3']
    ext_kwargs['include_dirs'] = [np.get_include()]
    ext_kwargs['extra_compile_args'] = ['-Wno-unused-function']
    # TODO why does it compile without these on OS X?!
    #c_ext.extra_compile_args += ['-framework OpenGL',
    #                             '-framework Cocoa', '-framework IOKit',
    #                             '-framework CoreVideo']


def module_to_path(module):
    return path.join('.', *module.split('.'))


# cythonize the .pyx file returning a suitable Extension
def cython_exts():
    return cythonize(
        [Extension(x, [module_to_path(x) + '.pyx'] + external_sources, **ext_kwargs) 
        for x in sources
    ])


setup(name='cyrasterize',
      version=versioneer.get_version(),
      cmdclass=versioneer.get_cmdclass(),
      description='Simple fast OpenGL offscreen rasterizing in Python',
      author='James Booth',
      author_email='james.booth08@imperial.ac.uk',
      url='https://github.com/menpo/cyrasterize/',
      classifiers=[
          'Development Status :: 3 - Alpha',
          'Intended Audience :: Developers',
          'Intended Audience :: Science/Research',
          'License :: OSI Approved :: BSD License',
          'Operating System :: OS Independent',
          'Programming Language :: C',
          'Programming Language :: Cython',
          'Programming Language :: Python :: 2',
          'Programming Language :: Python :: 3',
          'Programming Language :: Python :: 2.7',
          'Programming Language :: Python :: 3.4'
      ],
      ext_modules=cython_exts(),
      packages=find_packages(),
      package_data={'cyrasterize': package_data_globs},
      setup_requires=['numpy>=1.10'],
      install_requires=['numpy>=1.10'],
      include_dirs=[np.get_include()]
      )
