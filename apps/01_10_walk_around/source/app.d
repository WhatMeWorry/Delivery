
module app;  // 01_10_camera_view_space_walk_around

import common;

import gl3n.linalg; // vec3
import std.stdio;   // writeln
import std.math;    // sin cos

import derelict.util.loader;
import derelict.util.sharedlib;
import derelict.freetype.ft;
import derelict.openal.al;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

ManualTimer mt1;
AutoRestartTimer at2;

void moveCamera(Event event)
{
    // Camera controls
    GLfloat cameraSpeed = 0.01;

    if (event.keyboard.key == Key.w)
	{
        cameraPos += cameraSpeed * cameraFront;
		writeln("W key pressed cameraPos = ", cameraPos);
    }
    if (event.keyboard.key == Key.s)
    {
        cameraPos -= cameraSpeed * cameraFront;
   		writeln("S key pressed cameraPos = ", cameraPos);
    }     
    if (event.keyboard.key == Key.a)
    {
        cameraPos -= cross(cameraFront, cameraUp).normalized * cameraSpeed;
        writeln("A key pressed cameraPos = ", cameraPos);
    }
    if (event.keyboard.key == Key.d)
    {
        cameraPos += cross(cameraFront, cameraUp).normalized * cameraSpeed;
        writeln("D key pressed cameraPos = ", cameraPos);
    }
}


// Camera
vec3 cameraPos   = vec3(0.0f, 0.0f,  3.0f);
vec3 cameraFront = vec3(0.0f, 0.0f, -1.0f);
vec3 cameraUp    = vec3(0.0f, 1.0f,  0.0f);

// Window dimensions
const GLuint width = 800, height = 600;

void main(string[] argv)
{
	load_libraries();
	
	auto winMain = glfwCreateWindow(width, height, "Camera View Space Walk Around", null, null);
	
	glfwMakeContextCurrent(winMain); 
 
    // you must set the callbacks after creating the window
            glfwSetKeyCallback(winMain, &onKeyEvent);
      glfwSetCursorPosCallback(winMain, &onCursorPosition);
glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);
    glfwSetCursorEnterCallback(winMain, &onCursorEnterLeave); // triggered when cursor enters or leaves window

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
	
    // Setup OpenGL options
    glEnable(GL_DEPTH_TEST);	

    // Set up vertex data (and buffer(s)) and attribute pointers
    GLfloat[] vertices;
    initializeCube(vertices);

    // World space positions of our cubes
    vec3[] cubePositions;
    initializeCubePositions(cubePositions);
 
    GLuint VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.arraySizeInBytes, vertices.ptr, GL_STATIC_DRAW);

    // Position attribute    Data         Stride                        offset
    //                       length
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * GLfloat.sizeof, cast(const(void)*) 0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 5 * GLfloat.sizeof, cast(const(void)*) (3 * GLfloat.sizeof));
    glEnableVertexAttribArray(2);

    glBindVertexArray(0);   // Unbind VAO

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

    writeOnce!(cameraPos)();
    writeOnce!(cameraFront)();
    writeOnce!(cameraUp)();

    mt1.startTimer(3.0);
	
    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        if (mt1.expires)
        {
            writeln("mt1 expires");
            writeln("cameraPos = ", cameraPos);
            writeln("cameraFront = ", cameraFront);
            writeln("cameraUp = ", cameraUp);
 
            mt1.startTimer(3.0);			
        }

        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions 
        Event even;						   
        if (getNextEvent(winMain, even))
        {
            if (even.type == EventType.keyboard)
            {
                if (even.keyboard.key == Key.escape)
                    glfwSetWindowShouldClose(winMain, GLFW_TRUE);
                else					
                    moveCamera(even);
            }
        }
        // Render
        
        // Clear the colorbuffer
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Create transformations
        //mat4 model      = mat4.identity;
        mat4 view       = mat4.identity;
        mat4 projection = mat4.identity;

        view = view.translate(vec3(0.0f, 0.0f, -3.0f));

        view = mat4.look_at(cameraPos, cameraPos + cameraFront, cameraUp);

        projection = perspectiveFunc(toRadians(45.0), width/height, 0.1, 100.0);
 
        writeOnce!(projection)();
        writeMultiple!(projection, 2)();

        // Get their uniform location
        GLint modelLoc = glGetUniformLocation(programID, "model");
        GLint viewLoc  = glGetUniformLocation(programID, "view");
        GLint projLoc  = glGetUniformLocation(programID, "projection");
        // Pass the matrices to the shader
        glUniformMatrix4fv(viewLoc,  1, GL_TRUE, view.value_ptr);
        // Note: currently we set the projection matrix each frame, but since 
        // the projection matrix rarely changes it's often best practice to set 
        // it outside the main loop only once.
        glUniformMatrix4fv(projLoc,  1, GL_FALSE, projection.value_ptr);

        glBindVertexArray(VAO);
        for (GLuint i = 0; i < 10; i++)
        {
            // Calculate the model matrix for each object and pass it to shader before drawing
            mat4 model = mat4.identity;
          
            // the rotate and translate are in opposite order from the C++ code
			
            GLfloat angle = 1.01f * i;  // was 20.0f in C++ code
            model = model.rotate(angle, vec3(1.0f, 0.3f, 0.5f));

            model = model.translate(cubePositions[i]);

            glUniformMatrix4fv(modelLoc, 1, GL_TRUE, model.value_ptr);

            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        glBindVertexArray(0);

        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}


