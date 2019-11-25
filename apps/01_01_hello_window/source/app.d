
module app;  // 01_01_hello_window


import std.stdio;   // writeln
import std.system;  // defines enum OS  OS os = OS.win64;
import std.file;    // getcwd

import mytoolbox;   // printEnvVariable

import bindbc.glfw;   // glfwSwapBuffers, flgwPollEvents, glfwTerminate
import bindbc.opengl; // glClear, glClearColor

import dynamic_libs.glfw;      // without - Error: undefined identifier load_GLFW_Library
import dynamic_libs.opengl;    // without - Error: undefined identifier load_openGL_Library



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
        printEnvVariable("LIBRARY_PATH");     // compile and link time 
        printEnvVariable("LD_LIBRARY_PATH");  // run time      
    }
    version(OSX)
    {
        printEnvVariable("LIBRARY_PATH");     // compile and link time 
        printEnvVariable("LD_LIBRARY_PATH");  // run time        
        printEnvVariable("DYLD_LIBRARY_PATH");        
    }


    //printEnvVariable("LIBPATH");

    string currentWorkingDirectory = getcwd();  // this is where the exec was started from
                                                // we need this because all the libraries, resources,
                                                // will be relative to this location

    writeln("This executable was started at location: ", currentWorkingDirectory);


    load_GLFW_Library();

    load_openGL_Library();  

    //load_libraries();

    writeln("After load_libraries in app.d");

    auto window = glfwCreateWindow(width, height, "01_01_hello_window", null, null);
    glfwMakeContextCurrent(window);

    // Game loop
    while (!glfwWindowShouldClose(window))    // Loop until the user closes the window
    {
        // Check if any events have been activiated (key pressed, mouse moved etc.)
        // and call corresponding response functions
        glfwPollEvents();

        // Render

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);  // Clear the colorbuffer
        glClear(GL_COLOR_BUFFER_BIT);

        glfwSwapBuffers(window);    // Swap front and back buffers
    }

    glfwTerminate();   // clear any resources allocated by GLFW.

    return;
}
