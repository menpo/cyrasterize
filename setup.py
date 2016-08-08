from Cython.Build import cythonize
from setuptools import setup, find_packages, Extension
import os
import os.path as op
import platform
import pkg_resources
import versioneer
import fnmatch


INCLUDE_DIRS = [pkg_resources.resource_filename('numpy', 'core/include')]
LIBRARY_DIRS = []


SYS_PLATFORM = platform.system().lower()
IS_WIN = platform.system() == 'Windows'
IS_LINUX = 'linux' in SYS_PLATFORM
IS_OSX = 'darwin' == SYS_PLATFORM
IS_UNIX = IS_LINUX or IS_OSX
IS_CONDA = os.environ.get('CONDA_BUILD', False)


def walk_for_package_data(ext_pattern):
    paths = []
    for root, dirnames, filenames in os.walk('cyrasterize'):
        for filename in fnmatch.filter(filenames, ext_pattern):
            # Slice cyrasterize off the beginning of the path
            paths.append(
                op.relpath(os.path.join(root, filename), 'cyrasterize'))
    return paths


def gen_extension(path_name, sources):
    kwargs = {
        'sources': sources,
        'include_dirs': INCLUDE_DIRS,
        'library_dirs': LIBRARY_DIRS,
        'language': 'c++'
    }
    if IS_UNIX:
        kwargs['extra_compile_args'] = ['-Wno-unused-function']
        kwargs['libraries'] = ['m', 'GLEW', 'glfw']
        if IS_CONDA:
            conda_prefix = os.environ.get('PREFIX', '')
            kwargs['include_dirs'] += [op.join(conda_prefix, 'include')]
            kwargs['library_dirs'] += [op.join(conda_prefix, 'lib')]
    if IS_LINUX:
        kwargs['libraries'] += ['GL', 'GLU']
    if IS_WIN:
        kwargs['libraries'] = ['glew32', 'glfw3dll', 'OpenGL32', 'glu32']
        if IS_CONDA:
            kwargs['include_dirs'] += [os.environ.get('LIBRARY_INC', '')]
            kwargs['library_dirs'] += [os.environ.get('LIBRARY_LIB', ''),
                                       os.environ.get('LIBRARY_BIN', '')]
    return Extension(path_name, **kwargs)


cy_extensions = [
    gen_extension('cyrasterize.glrasterizer',
                  [op.join('cyrasterize', 'cpp', 'glrglfw.cpp'),
                   op.join('cyrasterize', 'cpp', 'glr.cpp'),
                   op.join('cyrasterize', 'glrasterizer.pyx')]),
    gen_extension('cyrasterize.shader',
                  [op.join('cyrasterize', 'shader.pyx')]),
    gen_extension('cyrasterize.c_opengl_debug',
                  [op.join('cyrasterize', 'c_opengl_debug.pyx')])
]


# Grab all the pyx and pxd Cython files for uploading to pypi
package_files = walk_for_package_data('*.p[xy][xd]')
package_files += walk_for_package_data('*.h')
package_files += walk_for_package_data('*.cpp')
package_files += walk_for_package_data('*.frag')
package_files += walk_for_package_data('*.vert')


setup(
    name='cyrasterize',
    version=versioneer.get_version(),
    cmdclass=versioneer.get_cmdclass(),
    description='Simple fast OpenGL offscreen rasterizing in Python',
    author='The Menpo Team',
    author_email='hello@menpo.org',
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
      'Programming Language :: Python :: 3.4',
      'Programming Language :: Python :: 3.5'
    ],
    ext_modules=cythonize(cy_extensions, force=IS_CONDA),
    packages=find_packages(),
    package_data={'cyrasterize': package_files},
    setup_requires=['numpy>=1.10'],
    install_requires=['numpy>=1.10']
)
