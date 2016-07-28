To develop
---------

It's easiest to do the whole build with conda as this will link the correct dependencies accross platforms:
```
CONDACI_VERSION=6.6.6 conda build ./conda/ --python=2.7
```
Note that `CONDACI_VERSION` just needs to be set, can be anything whilst you develop.

See the end of the build for the location of a tar.gz that you can install into an env for testing, e.g.:
```
conda install ~/miniconda3/conda-bld/osx-64/cyrasterize-6.6.6-np110py27_0.tar.bz2
```

