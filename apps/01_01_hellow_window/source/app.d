
module app;

import derelict_libraries;
import mytoolbox;   // printEnvVariable
import std.stdio;   // writeln
import std.system;  // defines enum OS  OS os = OS.win64;
import std.file;    // getcwd


const uint width = 800, height = 600;

void main(char[][] args)
{
    writeln("INSIDE APP.D  This program was compiled for a ", os, " system.");
    writeln("And called with the following arguments");
    foreach (arg; args)
    {
        writeln(arg);
    }

	printEnvVariable("PATH");

	version(Windows)
    {
	    printEnvVariable("LIB");
    }
    version(linux)
    {
        printEnvVariable("LD_LIBRARY_PATH");  // for Fmod library

    }

	//printEnvVariable("LIBPATH");

    string currentWorkingDirectory = getcwd();  // this is where the exec was started from
                                                // we need this because all the libraries, resources,
										        // will be relative to this location

    writeln("This executable was started at location: ", currentWorkingDirectory);

	load_libraries();

	auto winMain = glfwCreateWindow(width, height, "Hello Window", null, null);

	glfwMakeContextCurrent(winMain);

    // Game loop
    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        // Check if any events have been activiated (key pressed, mouse moved etc.)
		// and call corresponding response functions
        glfwPollEvents();

        // Render

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);  // Clear the colorbuffer
        glClear(GL_COLOR_BUFFER_BIT);

        glfwSwapBuffers(winMain);    // Swap front and back buffers
    }

    glfwTerminate();   // clear any resources allocated by GLFW.

	return;
}
