#version 330 core
layout (location = 0) in vec4 vertex; // <vec2 position, vec2 texCoords>

out vec2 TexCoords;

uniform mat4 model;
uniform mat4 projection;

void main()
{
    // Since Breakout is a static game, there is no need for a view/camera matrix 
    // so using the projection matrix we can directly transform the world-space 
    //coordinates to clip-space coordinates.

    TexCoords = vertex.zw;
    gl_Position = projection * model * vec4(vertex.xy, 0.0, 1.0);
}