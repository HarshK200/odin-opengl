#version 460

in vec2 TexCoords;
out vec4 FragColor;
layout(location = 0) uniform sampler2D texture1;

void main() {
    FragColor = texture(texture1, TexCoords);
}
