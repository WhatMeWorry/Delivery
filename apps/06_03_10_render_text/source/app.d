module app;


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

import resource_manager;
import texture_2d;
import sound;
import text_renderer;

import game; // without - Error:  undefined identifier Game

import dynamic_libs.glfw;       // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;     // without - Error: undefined identifier load_openGL_Library
import dynamic_libs.freeimage;  // without - Error: undefined identifier load_FreeImage_Library
import dynamic_libs.assimp;
import dynamic_libs.freetype;
import dynamic_libs.sdl;
import dynamic_libs.sdlmixer;


bool[1024] keys;

enum bool particulate = true;
enum bool effects     = true;
enum bool powUps      = true;
enum bool audio       = true;
enum bool screenText  = true;


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



TextRenderer textRend;

TextRenderingSystem textRenderSys;  // works

GLFWwindow* winMain;  // need to make global so post_processor can acces winMain;  Kludge.

void main(string[] argv)
{
    Game breakout = new Game(800, 600);  // originally (800, 600)  // (1600, 1200) for 4K monitors

    load_GLFW_Library();

    load_openGL_Library(); 

    load_FreeType_Library();

    load_FreeImage_Library();
    
    load_Assimp_Library();

    load_SDL_Library();

    load_SDL_Mixer_Library();    

    initAndOpenSoundAndLoadTracks();

    if (isMusicNotPlaying())
    {
        playSound("BREAKOUT");
	}

    winMain = glfwCreateWindow(breakout.width, breakout.height, "06_03_10_render_text", null, null);

    glfwMakeContextCurrent(winMain); 


    // you must set the callbacks after creating the window
          glfwSetCursorPosCallback(winMain, &onCursorPosition);
        glfwSetMouseButtonCallback(winMain, &onMouseButton);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);
        glfwSetCursorEnterCallback(winMain, &onCursorEnterLeave);

    // you must set the callbacks after creating the window
    glfwSetKeyCallback(winMain, &onInternalKeyEvent);

    // GLFW Options
    glfwSetInputMode(winMain, GLFW_CURSOR, GLFW_CURSOR_NORMAL);

    // Define the viewport dimensions
    //glViewport(0, 0, breakout.width, breakout.height);  // replaced with glfwGetFramebufferSize()
                                                          // for Mac OS.

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
                                           // relative to this file's location
    initTextRenderingSystem(textRenderSys, "./../../fonts/ocraext.ttf" );  // "../fonts/ocraext.ttf"

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


