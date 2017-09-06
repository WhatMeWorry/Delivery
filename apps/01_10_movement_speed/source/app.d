
module app;  // 01_10_movement_speed

import common;

import gl3n.linalg; // vec3
import std.math;    //  sin cose
import std.stdio;   // writeln

import derelict.util.loader;
import derelict.util.sharedlib;
import derelict.freetype.ft;
import derelict.openal.al;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;


float angle;
float distance = 3.0;
double time;
int    keyAction = 3;

bool firstMouse = true;

vec3 globalCameraPos;
vec3 globalCameraFront;
vec3 globalCameraUp;


void processMouse(double xpos, double ypos)
{
    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    GLfloat xoffset = xpos - lastX;
    GLfloat yoffset = lastY - ypos;  // Reversed since y-coordinates go from bottom to left
    lastX = xpos;
    lastY = ypos;

    GLfloat sensitivity = 0.05;  // Change this value to your liking
    xoffset *= sensitivity;
    yoffset *= sensitivity;

    yaw   += xoffset;
    pitch += yoffset;

    // Make sure that when pitch is out of bounds, screen doesn't get flipped
    if (pitch > 89.0f)
        pitch = 89.0f;
    if (pitch < -89.0f)
        pitch = -89.0f;

    vec3 front;
    front.x = cos(toRadians(yaw)) * cos(toRadians(pitch));
    front.y = sin(toRadians(pitch));
    front.z = sin(toRadians(yaw)) * cos(toRadians(pitch));
    cameraFront = front.normalized;
}


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


void enableCursor(Event event)
{
    if (event.cursor.state == CursorState.In)
    {
        // The cursor entered the client area of the window
        globalCameraPos   = cameraPos;
        globalCameraFront = cameraFront;
        globalCameraUp    = cameraUp;
    }
    else
    {
        // The cursor left the client area of the window
    }
}

 
// Window dimensions
enum width = 800;  enum height = 600;

// Camera
vec3 cameraPos   = vec3(0.0f, 0.0f,  3.0f);
vec3 cameraFront = vec3(0.0f, 0.0f, -1.0f);
vec3 cameraUp    = vec3(0.0f, 1.0f,  0.0f);


GLfloat yaw = -90.0f; // Yaw is initialized to -90.0 degrees since a yaw of 0.0 results 
// in a direction vector pointing to the right (due to how Eular 
// angles work) so we initially rotate a bit to the left.
GLfloat pitch =  0.0f;
GLfloat lastX =  width / 2.0;
GLfloat lastY =  height / 2.0;

// Deltatime
GLfloat deltaTime = 0.0f;   // Time between current frame and last frame
GLfloat lastFrame = 0.0f;   // Time of last frame


void main(string[] argv)
{
    //auto winMain = load_libraries();
    load_libraries();

    auto winMain = glfwCreateWindow(800, 600, "01_10_movement_speed", null, null);

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

//===================================================================================

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

    enum describeBuff = defineVertexLayout!(int)([3,2]);
    mixin(describeBuff);
    pragma(msg, describeBuff);
    /+
    // Position attribute    Data         Stride                        offset
    //                       length
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * GLfloat.sizeof, cast(const(void)*) 0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * GLfloat.sizeof, cast(const(void)*) (3 * GLfloat.sizeof));
    glEnableVertexAttribArray(2);
    +/

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

    angle = 0.0;

    writeOnce!(cameraPos)();
    writeOnce!(cameraFront)();
    writeOnce!(cameraUp)();

    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        // Calculate deltatime of current frame
        GLfloat currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;

        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions 

        //handleEvent(winMain);  // handleEvent will empty the queue so getNexEvent will never have anything to process     

        Event even;   
        if (getNextEvent(winMain, even))
        {
            if (even.type == EventType.keyboard)
            {
                if (even.keyboard.key == Key.escape)
                {
                    glfwSetWindowShouldClose(winMain, GLFW_TRUE);
                }                  
                else
                {
                    moveCamera(even);
                }
            }
            if (even.type == EventType.cursorInOrOut)
            {
                enableCursor(even);
            }
            if (even.type == EventType.cursorPosition)
            {
                processMouse(even.cursor.position.x, even.cursor.position.y);
            }
            if (even.type == EventType.frameBufferSize)
            {
                int pixelWidth, pixelHeight;
                glfwGetFramebufferSize(winMain, &pixelWidth, &pixelHeight);  
                glViewport(0, 0, pixelWidth, pixelHeight);
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
        writeMultiple!(projection, 1)();


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
          
            // rotate and translate are in opposite order as the C++ code
            GLfloat angle = 1.0f * i;
            model = model.rotate(angle, vec3(1.0f, 0.3f, 0.5f));

            //writeMultiple!(model, 10)();

            model = model.translate(cubePositions[i]);
            //writeln("model matrix = ", model);
            //GLfloat angle = 20.0f * i;
            //model = model.rotate(angle, vec3(1.0f, 0.3f, 0.5f));
            glUniformMatrix4fv(modelLoc, 1, GL_TRUE, model.value_ptr);

            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        glBindVertexArray(0);

        glfwSwapBuffers(winMain);   // Swap front and back buffers  
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}


