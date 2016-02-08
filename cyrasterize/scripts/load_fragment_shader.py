frag_shader = """#version 330
#extension GL_ARB_explicit_attrib_location : require

uniform sampler2D textureImage;
smooth in vec2 tcoord;
smooth in vec3 linearMappingCoord;

layout(location = 0) out vec4 outputColor;
layout(location = 1) out vec3 outputLinearMapping;

void main() {
   outputColor = texture(textureImage, tcoord);
      outputLinearMapping = linearMappingCoord;
      }
"""


import numpy as np
import menpo3d.io as mio
from cyrasterize import CyRasterizer
from cyrasterize import FragmentShader
import sip
sip.setapi('QString', 2)
sip.setapi('QVariant', 2)
mesh = mio.import_builtin_asset('james.obj')
CyRasterizer()
shader = FragmentShader(frag_shader)
print(shader)
