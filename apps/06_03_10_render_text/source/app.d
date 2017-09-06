module app;

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
import derelict.fmod.fmod;
//import derelict.fmod.common;

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




SoundSystem soundSys;  // Structure containing audio functionality

TextRenderer textRend;

TextRenderingSystem textRenderSys;  // works

GLFWwindow* winMain;  // need to make global so post_processor can acces winMain;  Kludge.

void main(string[] argv)
{
    Game breakout = new Game(800, 600);  // originally (800, 600)  // (1600, 1200) for 4K monitors

    load_libraries();

    initSoundSystem(soundSys);

    playSound(FMOD_LOOP_NORMAL, soundSys.system, "../audio/breakout.mp3");

    printDrivers();

    initSound(soundSys, FMOD_LOOP_NORMAL, "../audio/breakout.mp3");  // offset 0
    initSound(soundSys, FMOD_LOOP_OFF,    "../audio/bleep.mp3");     // offset 1
    initSound(soundSys, FMOD_LOOP_OFF,    "../audio/solid.wav");     // offset 2
    initSound(soundSys, FMOD_LOOP_OFF,    "../audio/powerup.wav");   // offset 3
    initSound(soundSys, FMOD_LOOP_OFF,    "../audio/bleep.wav");     // offset 4

    playSound(soundSys, 0 );

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

    initTextRenderingSystem(textRenderSys);

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


