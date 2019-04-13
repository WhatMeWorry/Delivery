
module app;  // 04_09_geometry_shader

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

    auto winMain = glfwCreateWindow(800, 600, "04_09_geometry_shader", null, null);

    glfwMakeContextCurrent(winMain); 

    // you must set the callbacks after creating the window

                glfwSetKeyCallback(winMain, &onKeyEvent);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);

    Shader[] shaders =
    [
             Shader(GL_VERTEX_SHADER, "source/vertexShader.glsl",      0),
           Shader(GL_FRAGMENT_SHADER, "source/fragmentShader.glsl",    0),
           Shader(GL_GEOMETRY_SHADER, "source/geometryShader.glsl",    0)
        //        (GL_COMPUTE_SHADER, "source/computeShader.glsl",     0),
        //   (GL_TESS_CONTROL_SHADER, "source/tessControlShader.glsl", 0), 
        //(GL_TESS_EVALUATION_SHADER, "source/tessEvalShader.glsl",    0)
    ];

    GLuint programID = createProgramFromShaders(shaders);

    writeln("programID = ", programID);


    GLfloat[] points = 
	[
        -0.5,  0.5, 1.0, 0.0, 0.0, // top-left
         0.5,  0.5, 0.0, 1.0, 0.0, // top-right
         0.5, -0.5, 0.0, 0.0, 1.0, // bottom-right
        -0.5, -0.5, 1.0, 1.0, 0.0  // bottom-left
    ];
	
    GLuint VAO, VBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
	
    glBindVertexArray(VAO);
	
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, points.bytes, points.ptr, GL_STATIC_DRAW);
	
    enum pattern = defineVertexLayout!(int)([2,3]);
    mixin(pattern);
    pragma(msg, pattern);
	
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
		
        // draw points
        glBindVertexArray(VAO);
             glDrawArrays(GL_POINTS, 0, 4);
        glBindVertexArray(0);
      
        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}



