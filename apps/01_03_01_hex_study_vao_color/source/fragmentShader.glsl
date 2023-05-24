#version 410 core

in  vec3 fColor;
out vec4 FragColor;

void main()
{
    //FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
	FragColor = vec4(fColor, 1.0);
}
