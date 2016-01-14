#version 330
#extension GL_ARB_explicit_attrib_location : require

uniform sampler2D textureImage;
uniform mat4 viewMatrix;

smooth in vec2 tcoord;
smooth in vec3 linearMappingCoord;
smooth in vec3 normalInterp;
smooth in vec3 FragPos;

uniform vec3 lightPos;

const float shininess = 16.0;

layout(location = 0) out vec4 outputColor;
layout(location = 1) out vec3 outputLinearMapping;

void main() {
   vec3 color = texture(textureImage, tcoord).rgb;
   vec3 ambient = 0.05 * color;

   vec3 lightDir = normalize(lightPos - FragPos);

   vec3 normal = normalize(normalInterp);
   float lambertian = max(dot(lightDir, normal), 0.0);
   vec3 diffuse = lambertian * color;

   vec3 viewDir = normalize(-FragPos);

   vec3 halfwayDir = normalize(lightDir + viewDir);

   float spec = pow(max(dot(halfwayDir, normal), 0.0), shininess);

   vec3 specular = vec3(0.3) * spec; // assuming bright white light color
   outputColor = min(vec4(ambient + diffuse + specular, 1.0f), 1);

   outputLinearMapping = linearMappingCoord;
}