

module app;  // 03_01_model_loading

import common;

import std.math;    // cos
import std.stdio;   // writeln
import std.conv;    // to
import gl3n.linalg; // vec3 mat4

import derelict.util.loader;
import derelict.util.sharedlib;

import bindbc.freetype;
import bindbc.freeimage;
import bindbc.opengl;
import bindbc.glfw;


// This just declares a _pointer_ to CameraClass that is set to null.  No Camera object is created.
Camera camera; 

bool firstMouse = true;

extern(C) static void onInternalKeyEvent(GLFWwindow* window, int key, int scancode, int action, int modifier) nothrow
{

    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
    if (key >= 0 && key < 1024)
    {
        if (action == GLFW_PRESS)
            keys[key] = true;
        else if (action == GLFW_RELEASE)
            keys[key] = false;
    }
}

extern(C) void mouse_callback(GLFWwindow* window, double xpos, double ypos) nothrow
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

    camera.ProcessMouseMovement(xoffset, yoffset);
}


extern(C) void mouseScrollWheel_callback(GLFWwindow* window, double xoffset, double yoffset) nothrow
{
    camera.ProcessMouseScrollWheel(yoffset);
}


void do_movement()
{
    // Camera controls
    if (keys[GLFW_KEY_W])
        camera.ProcessKeyboard(Camera_Movement.FORWARD, deltaTime);
    if (keys[GLFW_KEY_S])
        camera.ProcessKeyboard(Camera_Movement.BACKWARD, deltaTime);
    if (keys[GLFW_KEY_A])
        camera.ProcessKeyboard(Camera_Movement.LEFT, deltaTime);
    if (keys[GLFW_KEY_D])
        camera.ProcessKeyboard(Camera_Movement.RIGHT, deltaTime);
}



extern(C) void onWindowResize(GLFWwindow* window, int width, int height) nothrow
{
    int pixelWidth, pixelHeight;
    glfwGetFramebufferSize(window, &pixelWidth, &pixelHeight);  
    glViewport(0, 0, pixelWidth, pixelHeight);
}



// Window dimensions
enum width = 800;  enum height = 600;


GLfloat lastX =  width / 2.0;
GLfloat lastY =  height / 2.0;
bool[256] keys;

// Light attributes
vec3 lightPos = vec3(1.2f, 1.0f, 2.0f);

// Deltatime
GLfloat deltaTime = 0.0f;  // Time between current frame and last frame
GLfloat lastFrame = 0.0f;  // Time of last frame

Shader shader;

void main(string[] argv)
{
    camera = new Camera(vec3(0.0f, 0.0f, 3.0f));
 
    load_libraries();

    auto winMain = glfwCreateWindow(800, 600, "03_01_model_loading", null, null);

    glfwMakeContextCurrent(winMain); 

    // you must set the callbacks after creating the window
   
          glfwSetCursorPosCallback(winMain, &mouse_callback); 
                glfwSetKeyCallback(winMain, &onInternalKeyEvent);
             glfwSetScrollCallback(winMain, &mouseScrollWheel_callback);
         glfwSetWindowSizeCallback(winMain, &onWindowResize);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);    
 
    // Define the viewport dimensions
    glViewport(0, 0, width, height);

    // Setup OpenGL options
    glEnable(GL_DEPTH_TEST);

    Shader[] shaders =
    [
          Shader(GL_VERTEX_SHADER, "source/VertexShader.glsl",   0),
        Shader(GL_FRAGMENT_SHADER, "source/FragmentShader.glsl", 0)
    ];

    shader.ID = createProgramFromShaders(shaders);

    // Load models
    Model ourModel = new Model("../models/nanosuit.obj");

    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        // Calculate deltatime of current frame
        GLfloat currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;

        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions
        handleEvent(winMain); 
        do_movement();

        // Clear the colorbuffer
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glUseProgram(shader.ID);

        // Transformation matrices
        mat4 projection = mat4.identity;  // is this needed????
        projection = perspectiveFunc(camera.zoom, width/height, 0.1f, 100.0f);

        mat4 view = mat4.identity;     // is this needed????
        view = camera.GetViewMatrix();

        glUniformMatrix4fv(glGetUniformLocation(shader.ID, "projection"), 1, GL_FALSE, projection.value_ptr);
        glUniformMatrix4fv(glGetUniformLocation(shader.ID, "view"), 1, GL_TRUE, view.value_ptr);

        // Draw the loaded model
        mat4 model = mat4.identity;
        model = model.translate(vec3(0.0f, -1.75f, 0.0f)); // Translate it down a bit so it's at the center of the scene
        model = model.scale(0.2f, 0.2f, 0.2f);             // It's a bit too big for our scene, so scale it down
        glUniformMatrix4fv(glGetUniformLocation(shader.ID, "model"), 1, GL_TRUE, model.value_ptr);
        ourModel.draw(shader);       

        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}