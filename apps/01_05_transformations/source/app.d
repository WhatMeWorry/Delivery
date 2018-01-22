
module app;  // 01_05_transformations

import common;
import common_game;

import std.stdio;   // writeln
import gl3n.linalg; // mat4

import derelict.util.loader;
import derelict.util.sharedlib;
import derelict.freetype.ft;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;



void main(string[] argv)
{
    load_libraries();
    
    auto winMain = glfwCreateWindow(800, 600, "01_05_transformations", null, null);
    
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

    GLint MaxTextureImageUnits;
    glGetIntegerv(GL_MAX_TEXTURE_IMAGE_UNITS, &MaxTextureImageUnits);
    writeln("The OpenGL 4.0 standard defines a minimum of 16 texture image units");
    writeln("GL_MAX_TEXTURE_IMAGE_UNITS supported on this card is ", MaxTextureImageUnits); 
 
    // Set up vertex data (and buffer(s)) and attribute pointers
    GLfloat[] vertices = 
    [
         //  Positions         Colors      Texture Coords
         0.5,  0.5, 0.0,   1.0, 0.0, 0.0,   1.0f, 1.0, // Top Right
         0.5, -0.5, 0.0,   0.0, 1.0, 0.0,   1.0f, 0.0, // Bottom Right
        -0.5, -0.5, 0.0,   0.0, 0.0, 1.0,   0.0f, 0.0, // Bottom Left
        -0.5,  0.5, 0.0,   1.0, 1.0, 0.0,   0.0f, 1.0  // Top Left 
    ];

    GLuint[] indices =   // Note that we start from 0
    [
        0, 1, 3, // First Triangle
        1, 2, 3  // Second Triangle
    ];

    GLuint VBO, VAO, EBO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.bytes, vertices.ptr, GL_STATIC_DRAW);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.bytes, indices.ptr, GL_STATIC_DRAW);

    enum describeBuff = defineVertexLayout!(int)([3,3,2]);
    mixin(describeBuff);
    pragma(msg, describeBuff);   

    /+
    // Position attribute    Data         Stride                        offset
    //                       len
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) 0);
    glEnableVertexAttribArray(0);
    // Color attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (3 * GLfloat.sizeof));
    glEnableVertexAttribArray(1);
    // TexCoord attribute
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (6 * GLfloat.sizeof));
    glEnableVertexAttribArray(2);
    +/

    glBindVertexArray(0); // Unbind VAO

    // Load and create a texture 
    GLuint texture1;
    GLuint texture2;

    loadTexture(texture1, "../art/container.jpg");
    loadTexture(texture2, "../art/awesomeface.png");

    // Bind Textures using texture units

    // OpenGL should have a at least a minimum of 16 texture units for you to use 
    // which you can activate using GL_TEXTURE0 to GL_TEXTURE15. They are deﬁned in 
    // order so we could also get GL_TEXTURE8 via GL_TEXTURE0 + 8 for example, which 
    // is useful when we’d have to loop over several texture units.

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glUniform1i(glGetUniformLocation(programID, "ourTexture1"), 0);

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);
    glUniform1i(glGetUniformLocation(programID, "ourTexture2"), 1);

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

        // Create transformations
        mat4 transform = mat4.identity;
        //mat4 transform;  // causes empty screen.  Must use = mat4.identity
  
        // opposite order from C++ and OpenGL and GLM
        transform = transform.rotate(cast(GLfloat) glfwGetTime() * 1.0f, vec3(0.0f, 0.0f, -1.0f));  // negative sign
        transform = transform.translate(vec3(0.25f, -0.25f, 0.0f));

        double runningTimeInSeconds = glfwGetTime();
        int runTimeInSecs = cast(int) runningTimeInSeconds;

        // Get matrix's uniform location and set matrix
        GLint transformLoc = glGetUniformLocation(programID, "transform");
        glUniformMatrix4fv(transformLoc, 1, GL_TRUE, transform.value_ptr);

        // Draw container
        glBindVertexArray(VAO);
            glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, cast(const(void)*) 0);
        glBindVertexArray(0);
      
        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}


