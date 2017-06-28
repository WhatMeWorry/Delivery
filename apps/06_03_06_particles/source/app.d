
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


enum bool particulate = true;
enum bool effects     = false;
enum bool powUps      = true;
enum bool audio       = false;
enum bool screenText  = false;


bool[1024] keys;

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

void main(string[] argv)
{
    Game breakout = new Game(800, 600);  // originally (800, 600)  // (1600, 1200) for 4K monitors
	
    load_libraries();
	
    auto winMain = glfwCreateWindow(breakout.width, breakout.height, "06_03_06_particles", null, null);
		
    glfwMakeContextCurrent(winMain); 

    // you must set the callbacks after creating the window
    glfwSetKeyCallback(winMain, &onInternalKeyEvent);	
	
    // GLFW Options
    glfwSetInputMode(winMain, GLFW_CURSOR, GLFW_CURSOR_NORMAL);	
	
    // Define the viewport dimensions
    glViewport(0, 0, breakout.width, breakout.height);

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

        deltaTime = 0.001f;
        // Manage user input
        breakout.processInput(deltaTime);

        // Update Game state
		
        breakout.update_04(deltaTime);
 		
        // Render
        //glClearColor(0.1f, 0.3f, 0.4f, 1.0f);  // originally
		glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

		breakout.renderGameWithParticles();
		
        glfwSwapBuffers(winMain);
    }
    return;
}

