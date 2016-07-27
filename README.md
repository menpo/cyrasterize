To develop
---------

E.g.
```
CONDACI_VERSION=6.6.6 conda build ./conda/ --python=2.7 && conda install ~/miniconda3/conda-bld/osx-64/cyrasterize-6.6.6-np110py27_0.tar.bz2
```
Make sure to kill .cpp files or Cython doesn't seem to compile...