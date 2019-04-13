

module app;

import common;
import common_game;


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

enum bool particulate = false;
enum bool effects     = false;
enum bool powUps      = false;
enum bool audio       = false;
enum bool screenText  = false;


void main(string[] argv)
{
    Game breakout = new Game(800, 600);

    load_libraries();

    auto winMain = glfwCreateWindow(breakout.width, breakout.height, "06_03_02_beakout_setup", null, null);

    glfwMakeContextCurrent(winMain); 

    // Define the viewport dimensions
    glViewport(0, 0, breakout.width, breakout.height);

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


    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {     
        // Calculate delta time
        GLfloat currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
        glfwPollEvents();

        //deltaTime = 0.001f;
        // Manage user input
        breakout.processInput(deltaTime);

        // Update Game state
        breakout.update(deltaTime);

        // Render
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        breakout.render();

        glfwSwapBuffers(winMain);
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}


