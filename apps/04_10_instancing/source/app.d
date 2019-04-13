
module app;  // 04_10_instancing

//import common;
import shaders;
import texturefuncs;
import mytoolbox;
import derelict_libraries;
import event_handler;

import common_game;

import std.stdio;  // writeln
import std.conv;   // toChars

import gl3n.linalg; // vec2

import derelict.util.loader;
import derelict.util.sharedlib;

import bindbc.freetype;
import bindbc.freeimage;
import bindbc.opengl;
import bindbc.glfw;
     

void main(string[] argv)
{
    load_libraries();

    auto winMain = glfwCreateWindow(800, 600, "04_10_instancing", null, null);

    glfwMakeContextCurrent(winMain); 

    // you must set the callbacks after creating the window

                glfwSetKeyCallback(winMain, &onKeyEvent);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);

    Shader[] shaders =
    [
             Shader(GL_VERTEX_SHADER, "source/vertexShader.glsl",      0),
           Shader(GL_FRAGMENT_SHADER, "source/fragmentShader.glsl",    0)
        //       (GL_GEOMETRY_SHADER, "source/geometryShader.glsl"     0),
        //        (GL_COMPUTE_SHADER, "source/computeShader.glsl",     0),
        //   (GL_TESS_CONTROL_SHADER, "source/tessControlShader.glsl", 0), 
        //(GL_TESS_EVALUATION_SHADER, "source/tessEvalShader.glsl",    0)
    ];

    GLuint programID = createProgramFromShaders(shaders);

    writeln("programID = ", programID);

    // generate a list of 100 quad locations/translation-vectors

    vec2[100] offsets;

    int i = 0;
    float off = 0.1;
    for (int y = -10; y < 10; y += 2)
    {
        for (int x = -10; x < 10; x += 2)
        {
            vec2 offset;
            offset.x = (x / 10.0) + off;
            offset.y = (y / 10.0) + off;
            offsets[i++] = offset;
        }
    }

    writeln("offsets = ", offsets);

    // store instance data in an array buffer
	
    GLuint instanceVBO;
    glGenBuffers(1, &instanceVBO);
    glBindBuffer(GL_ARRAY_BUFFER, instanceVBO);
    //glBufferData(GL_ARRAY_BUFFER, offsets.bytes, &offsets[0], GL_STATIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, offsets.bytes, &offsets, GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, 0);	
	
	
    // set up vertex data (and buffer(s)) and configure vertex attributes

    GLfloat[] quadVertices = 
	[
        // positions     // colors
        -0.05,  0.05,  1.0, 0.0, 0.0,
         0.05, -0.05,  0.0, 1.0, 0.0,
        -0.05, -0.05,  0.0, 0.0, 1.0,

        -0.05,  0.05,  1.0, 0.0, 0.0,
         0.05, -0.05,  0.0, 1.0, 0.0,
         0.05,  0.05,  0.0, 1.0, 1.0
    ];
	
    GLuint quadVAO, quadVBO;
    glGenVertexArrays(1, &quadVAO);
    glGenBuffers(1, &quadVBO);
	
    glBindVertexArray(quadVAO);
	
    glBindBuffer(GL_ARRAY_BUFFER, quadVBO);
    glBufferData(GL_ARRAY_BUFFER, quadVertices.bytes, quadVertices.ptr, GL_STATIC_DRAW);
	
    enum pattern = defineVertexLayout!(int)([2,3]);
    mixin(pattern);
    pragma(msg, pattern);

    // also set instance data
    glEnableVertexAttribArray(2);
    glBindBuffer(GL_ARRAY_BUFFER, instanceVBO); // this attribute comes from a different vertex buffer
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 2 * GLfloat.sizeof, cast(const(void)*) (0 * GLfloat.sizeof));
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glVertexAttribDivisor(2, 1);        // tell OpenGL this is an instanced vertex attribute
	
    glBindVertexArray(0); // Unbind VAO

    glUseProgram(programID);

    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions  
        handleEvent(winMain);   
        // Render
        
        // Clear the colorbuffer
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        // draw 100 instanced quads
		
        // Draw container
        glBindVertexArray(quadVAO);
            glDrawArraysInstanced(GL_TRIANGLES, 0, 6, 100);
        glBindVertexArray(0);
      
        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}



