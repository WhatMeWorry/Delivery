
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

enum bool particulate = false;
enum bool effects     = false;
enum bool powUps      = false;
enum bool audio       = false;
enum bool screenText  = false;

SoundSystem soundSys;  // Structure containing audio functionality

void main(string[] argv)
{
    Game breakout = new Game(800, 600);
	
    load_libraries();
	
    auto winMain = glfwCreateWindow(breakout.width, breakout.height, "06_03_03_breakout_sprites", null, null);
		
    glfwMakeContextCurrent(winMain); 

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
	

	writeAndPause("Before breakout.init");	
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

        //writeln("x = ", x);							
        //writeAndPause("Here");

        glfwSwapBuffers(winMain);
    }
    return;
}