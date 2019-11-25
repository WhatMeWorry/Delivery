
module derelict_libraries;


/+
public import bindbc.glfw;       
public import bindbc.opengl;
public import bindbc.freeimage;
public import bindbc.freetype;
public import derelict.util.exception;   // needed for the return type enum ShouldThrow.
public import derelict.util.sharedlib;
public import derelict.assimp3.assimp;
public import bindbc.sdl;

public import bindbc.sdl.mixer;
public import core.stdc.stdlib : exit;

import std.stdio;



ShouldThrow myMissingSymCallBackASSIMP3( string symbolName )
{
    if (symbolName == "aiReleaseExportFormatDescription"  ||  // Windows assimp.dll
        symbolName == "aiGetImportFormatCount"            ||
        symbolName == "aiGetImportFormatDescription"
       )
    {
       return ShouldThrow.No;
    }
    else
    {
        return ShouldThrow.Yes;
    }
}



void load_libraries()
{
    writeln("ENTERING LOAD_LIBRARIES");
 
    load_GLFW_Library();  

    load_FreeImage_Library();

    // require the use of OpenGL version 4.1 at the very least

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);    // Lenovo Tiny PCs are at openGL 4.2    Lian Li PC-33B is OpenGL 4.4
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);    // iMac 27" are at opengl 4.1   Surface Book is at opengl 4.1

     // require a context that only supports the new OpenGL core functionality.

    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    // The Compatibility Profile, which contains all the features.
      
    version(OSX)   // must be set for Mac Os
    {
        glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    }
    
    
    // Create an OpenGL context with another library (in this case, GLFW 3)

    auto window = glfwCreateWindow(100, 100, "Temp Context Window", null, null);

    writeln("window = ", window);

    if (!window)
    {
        throw new Exception("Window Creation Failed.");
    }

    glfwMakeContextCurrent(window);

    load_openGL_Library();

    glfwDestroyWindow(window);

  
    load_FreeType_Library();    
 

    load_SDL_Library();

    load_SDL_Mixer_Library();

    DerelictASSIMP3.missingSymbolCallback = &myMissingSymCallBackASSIMP3;

    DerelictASSIMP3.load();   // Load the Assimp3 library.

    // Now Assimp3 functions can be called.
}


+/