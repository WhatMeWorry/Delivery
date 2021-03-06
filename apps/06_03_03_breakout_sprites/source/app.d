
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


import game; // without - Error:  undefined identifier Game

import dynamic_libs.glfw;       // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;     // without - Error: undefined identifier load_openGL_Library
import dynamic_libs.freeimage;  // without - Error: undefined identifier load_FreeImage_Library
import dynamic_libs.assimp;
import dynamic_libs.freetype;


enum bool particulate = false;
enum bool effects     = false;
enum bool powUps      = false;
enum bool audio       = false;
enum bool screenText  = false;


void main(string[] argv)
{
    Game breakout = new Game(800, 600);

    load_GLFW_Library();

    load_openGL_Library(); 

    load_FreeType_Library();

    load_FreeImage_Library();
    
    load_Assimp_Library();


    auto winMain = glfwCreateWindow(breakout.width, breakout.height, "06_03_03_breakout_sprites", null, null);

    glfwMakeContextCurrent(winMain); 

    // you must set the callbacks after creating the window
 
                glfwSetKeyCallback(winMain, &onKeyEvent);
          glfwSetCursorPosCallback(winMain, &onCursorPosition);
        glfwSetMouseButtonCallback(winMain, &onMouseButton);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);
        glfwSetCursorEnterCallback(winMain, &onCursorEnterLeave);    

    // GLFW Options
    glfwSetInputMode(winMain, GLFW_CURSOR, GLFW_CURSOR_NORMAL);

    //===============================================================
    writeln("breakout.width = ", breakout.width);
    writeln("breakout.height = ", breakout.height);



    int fbw;
    int fbh;
    glfwGetFramebufferSize(winMain, &fbw, &fbh);

    writeln("Framebuffer size width = ", fbw);
    writeln("Framebuffer size height = ", fbh);

    int ww;
    int wh;
    glfwGetWindowSize(winMain, &ww, &wh);

    writeln("Window size width = ", ww);
    writeln("Window size height = ", wh);

    showMonitorVideoMode();

    //===============================================================



    // Define the viewport dimensions
    //glViewport(0, 0, breakout.width, breakout.height);  // replaced with glfwGetFramebufferSize()
                                                          // for Mac OS.

    int w;
    int h;
    glfwGetFramebufferSize(winMain, &w, &h);
    glViewport(0, 0, w, h);
    
    // Set OpenGL options
    glEnable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    // Initialize game
    breakout.init();

    // DeltaTime variables
    GLfloat deltaTime = 0.0f;
    GLfloat lastFrame = 0.0f;

    // Start Game within Menu State
    breakout.state = GameState.GAME_ACTIVE;

    // how to create and apply textures to 3D geometry data...
    int x = 0;
    float r = 0.001;

    Texture2D tex = resource_manager.ResMgr.getTexture("face");

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
        breakout.update(deltaTime);

        // Render
        glClearColor(0.1f, 0.3f, 0.4f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        //x =+ 5;  // surprised this compiled
        x += 1;
        r += 0.01;   // .005; 

        if (x > 400)
        {
            x = 0;
        }

        renderer.drawSprite(tex, 
                            vec2(0+x, 0+x),          // position,  originally 200, 200
                            vec2(200+x, 200+x),      // originally 300, 400
                            r,                       // -45.0f originally
                            vec3(0.0f, 1.0f, 0.0f));

        glfwSwapBuffers(winMain);
    }
    return;
}