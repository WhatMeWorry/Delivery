
#version 410 core  // This must stay at 330 for this project to work

in  vec2 TexCoords;
out vec4 color;

uniform sampler2D image;

uniform vec3      spriteColor;

void main()
{    
    // color = vec4(spriteColor, 1.0) * texture(image, TexCoords);  // old
    color = vec4(spriteColor, 1.0) * vec4(texture(image, TexCoords).rgb, 1.0);
}  