
module app;   // 06_02_text_rendering

import std.math;    // cos
import std.stdio;   // writeln
import std.conv;    // to
import gl3n.linalg; // vec3 mat4

import std.stdio : writeln; 

import shaders;         // without - Error: undefined identifier Shader, createProgramFromShaders, ...
import event_handler;   // without - Error: undefined identifier onKeyEvent, onFrameBufferResize, handleEvent
import mytoolbox;       // without - Error: no property bytes for type float[]
import cameraModule;    // withoug - Error: undefined identifier Camera
import projectionfuncs; // without - Error: undefined identifier orthographicFunc 
import monitor;         // without - Error: undefined identifier showAllMonitors, showMonitorVideoMode
import texturefuncs;    // without - Error: undefined identifier loadTexture
import vertex_data;     // without - Error: undefined identifier initializeCube, initializeCubePositions
import timer;           // without - Error:  undefined identifier ManualTimer, AutoRestartTimer
import model;           // without - Error:  undefined identifier model
import freetypefuncs;


import dynamic_libs.glfw;       // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;     // without - Error: undefined identifier load_openGL_Library
import dynamic_libs.freeimage;  // without - Error: undefined identifier load_FreeImage_Library
import dynamic_libs.assimp;
import dynamic_libs.freetype;

float angle;
float distance = 3.0;

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
bool[1024] keys;

// Light attributes
vec3 lightPos = vec3(1.2f, 1.0f, 2.0f);

// Deltatime
GLfloat deltaTime = 0.0f;  // Time between current frame and last frame
GLfloat lastFrame = 0.0f;  // Time of last frame

Glyph[GLchar] courierBold;
Glyph[GLchar] phoenixRising;
Glyph[GLchar] eagleLake;
GLuint VAO, VBO;

// In D all classes are references
// This just declares a _pointer_ to Camera class that is set to null.  No Camera object is created.
Camera camera;  

// In D, all structs are value types.  This will actually create an object called textRenderSys
TextRenderingSystem textRenderSys;
TextRenderingSystem textRenderSys1;
TextRenderingSystem textRenderSys2;
TextRenderingSystem textRenderSys3;

void main(string[] argv)
{
    load_GLFW_Library();

    load_openGL_Library(); 

    load_FreeType_Library();

    auto winMain = glfwCreateWindow(800, 600, "06_02_text_rendering", null, null);

    glfwMakeContextCurrent(winMain); 

    // you must set the callbacks after creating the window
  
           glfwSetKeyCallback(winMain, &onInternalKeyEvent);
    glfwSetWindowSizeCallback(winMain, &onWindowResize);
 
    // Define the viewport dimensions
    glViewport(0, 0, width, height);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    string[] fonts = [ "../fonts/ocraext.ttf",  "../fonts/EagleLake-Regular.ttf", 
                      "../fonts/courbd.ttf", "../fonts/phoenixrising.ttf" ];

    initTextRenderingSystem(textRenderSys, fonts[0]);
    writeln("textRenderSys.progID = ", textRenderSys.progID);
    writeln("textRenderSys.VAO = ", textRenderSys.VAO);
    writeln("textRenderSys.VBO = ", textRenderSys.VBO);

    initTextRenderingSystem(textRenderSys1, fonts[1]);
    initTextRenderingSystem(textRenderSys2, fonts[2]);
    initTextRenderingSystem(textRenderSys3, fonts[3]);



    auto RED = vec3(1.0, 0.0, 0.0);

    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {     
        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions 

        // Clear the colorbuffer
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        renderText(textRenderSys.font, textRenderSys.VAO, textRenderSys.VBO, textRenderSys.progID, 
                   "Courier Bold text at (x,y) = (0.0)", 0.0f, 0.0f, 1.5f, vec3(0.0, 0.0f, 0.0f));

        // Play with scale value
        renderText(textRenderSys1.font, textRenderSys1.VAO, textRenderSys1.VBO, textRenderSys1.progID,
                   "This changes scale to 0.5", 350.0f, 350.0f, 2.5f, vec3(0.0, 1.0f, 0.0f));

        renderText(textRenderSys2.font, textRenderSys2.VAO, textRenderSys2.VBO, textRenderSys2.progID,
                   "Phoenix Rising  scale = 2.33", 25.0f, 150.0f, 2.33f, RED);

        renderText(textRenderSys3.font, textRenderSys3.VAO, textRenderSys3.VBO, textRenderSys3.progID,
                   "(C) Eagle Lake LearnOpenGL.com", 25.0f, 500.0f, 1.0f, vec3(0.8, 0.8f, 0.8f));

        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}


