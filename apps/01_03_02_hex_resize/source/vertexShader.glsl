#version 410 core

layout (location = 0) in vec3 aPos;

uniform float reciprocalWindowScale;

uniform mat4 view;
uniform mat4 projection;  // values for orthographic 

void main()
{
    float rWS = reciprocalWindowScale;

    mat3 window_scale = mat3(
        vec3( rWS, 0.0, 0.0),  // reciprocal of the aspect ratio
        vec3( 0.0, 1.0, 0.0),
        vec3( 0.0, 0.0, 1.0)
    );
    //gl_Position = projection * view * model * vec4(position, 1.0f);  // from 01_10_orthographic

    // gl_Position = vec4(window_scale * aPos.xyz, 1.0) * view;  // THIS WORKED!!  AMBER
    gl_Position = projection * view * vec4(window_scale * aPos.xyz, 1.0);
    //gl_Position = view * vec4(window_scale * aPos.xyz, 1.0) * view;   // THIS MAKES VERY SMALL!! 
    //gl_Position = projection * vec4(window_scale * aPos.xyz, 1.0);   
    //gl_Position = projection * vec4(aPos.xyz, 1.0);      
}
