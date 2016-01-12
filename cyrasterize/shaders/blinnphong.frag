#version 330
#extension GL_ARB_explicit_attrib_location : require

uniform sampler2D textureImage;
uniform vec3 lightPos;

smooth in vec2 tcoord;
smooth in vec3 linearMappingCoord;
smooth in vec3 normal;

layout(location = 0) out vec4 outputColor;
layout(location = 1) out vec3 outputLinearMapping;


void main() {
    vec3 color = texture(textureImage, tcoord).rgb;

    // Ambient
    vec3 ambient = 0.05 * color;

    // Diffuse
    vec3 lightDir = normalize(lightPos - fs_in.FragPos);
    vec3 normal = normalize(fs_in.Normal);
    float diff = max(dot(lightDir, normal), 0.0);
    vec3 diffuse = diff * color;

    // Specular
    vec3 viewDir = normalize(viewPos - fs_in.FragPos);
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = 0.0;

    vec3 halfwayDir = normalize(lightDir + viewDir);
    spec = pow(max(dot(normal, halfwayDir), 0.0), 32.0);

    vec3 specular = vec3(0.3) * spec; // assuming bright white light color
    outputColor = vec4(ambient + diffuse + specular, 1.0f);
    outputLinearMapping = linearMappingCoord;
}