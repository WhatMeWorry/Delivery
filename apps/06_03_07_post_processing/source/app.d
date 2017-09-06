module app;  // 06_03_07_post_processing

import common;
import common_game;

import std.math;    // cos
import std.stdio;   // writeln
import std.conv;    // to
import gl3n.linalg; // vec3 mat4

import derelict.util.loader;
import derelict.util.sharedlib;
import derelict.freetype.ft;
import derelict.openal.al;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

bool[1024] keys;

enum bool particulate = true;
enum bool effects     = true;
enum bool powUps      = false;
enum bool audio       = false;
enum bool screenText  = false;


extern(C) static void onInternalKeyEvent(GLFWwindow* window, int key, int scancode, int action, int modifier) nothrow
{
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
    if (key >= 0 && key < 1024)
    {
        if (action == GLFW_PRESS)
            Game.keys[key] = true;
        else if (action == GLFW_RELEASE)
            Game.keys[key] = false;
    }
}

/+

But where is the basic unit to hold this code? Well, a code block of course, or a scope. 
Ideally, we would like a way to group all the previous declaration into one unit, with the same parameter list:

// scope?
(Type)
{
    struct Tree { /* using Type here */}
    Tree mapOnTree(Tree input, Tree delegate(Tree) f) { /* here also */ }
    void printTree(Tree input) { /* the same */ }
    alias TreeArray = Tree[]; // You get it
}

Since we will need to 'call' it to produce some code (a bit like you'd call a function), this code block needs a 
name. And then, we just need to tell the compiler: 'here, this is a blueprint'. The D keyword for that is (you got it) 
template{.d}:

To instantiate a template, use the following syntax:

templateName!(list, of, arguments)
Note the exclamation point (!) before the comma-separated argument list. That's what differentiate template arguments lists from standard (funtion) argument lists. If both are present (for function templates), we will use:

templateName!(template, argument, list)(runtime, agument, list)

================================================================================================

static if (compileTimeExpression)
{
     /* Code created if compileTimeExpression is evaluated to true */
}

Something really important here is a bit of compiler magic: once the code path is selected, the resulting code is instantiated in the template body, but without the curly braces. Otherwise that would create a local scope, hiding what's happening inside and would drastically limit the power of static if. So the curly braces are there only to group the statements together.


+/

GLFWwindow* winMain;  // need to make global so post_processor can acces winMain;  Kludge.


void main(string[] argv)
{
    Game breakout = new Game(800, 600);  // originally (800, 600)  // (1600, 1200) for 4K monitors

    load_libraries();

    winMain = glfwCreateWindow(breakout.width, breakout.height, "06_03_07_post_processing", null, null);

    glfwMakeContextCurrent(winMain); 

    showMonitorVideoMode();   

    // you must set the callbacks after creating the window
          glfwSetCursorPosCallback(winMain, &onCursorPosition);
        glfwSetMouseButtonCallback(winMain, &onMouseButton);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);
        glfwSetCursorEnterCallback(winMain, &onCursorEnterLeave);            
                glfwSetKeyCallback(winMain, &onInternalKeyEvent);

    // GLFW Options
    glfwSetInputMode(winMain, GLFW_CURSOR, GLFW_CURSOR_NORMAL);

    // Define the viewport dimensions
    int pixelWidth, pixelHeight;
    glfwGetFramebufferSize(winMain, &pixelWidth, &pixelHeight);  
    glViewport(0, 0, pixelWidth, pixelHeight);

    // Set OpenGL options
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // Initialize game
    breakout.initGame();

    // DeltaTime variables
    GLfloat deltaTime = 0.0f;
    GLfloat lastFrame = 0.0f;

    // Start Game within Menu State
    breakout.state = GameState.GAME_ACTIVE;

    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {     
        // Calculate delta time
        GLfloat currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        glfwPollEvents();

        handleEvent(winMain);           

        deltaTime = 0.001f;
        // Manage user input
        breakout.processInput(deltaTime);

        // Update Game state

        breakout.update_04(deltaTime);

        // Render
 
        glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        breakout.renderGameWithParticles();

        glfwSwapBuffers(winMain);
    }
    return;
}

