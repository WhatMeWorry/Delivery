
module dynamic_libs.glfw;

public import bindbc.glfw;

import std.stdio;
import core.stdc.stdlib;  // : exit

void load_GLFW_Library()
{
    // glfwSupport is set to GLFWSupport.gl30, gl31, or .gl32 during compile time depending on 
    // what is in dub.sdl file.

    writeln("The dub.sdl file of this project expects GLFW version ", glfwSupport);

    immutable GLFWSupport glfwLib = loadGLFW();

    writeln("GLFW version detected on this system is ", glfwLib);

    if (glfwLib == GLFWSupport.noLibrary) 
    {
        writeln("No FreeImage shared library was detected");
        exit(0);        
    }
    else if (glfwLib == GLFWSupport.badLibrary) 
    {
        writeln("One or more symbols failed to load. The likely cause is that the shared");
        writeln("library has a lower version than bindbc-freeimage was configured for");       
        exit(0);                
    }

    // The function isGLFWLoaded returns true if any version of GLFW was successfully loaded and false otherwise.
 
    if (isGLFWLoaded())
    {
        immutable GLFWSupport glfwVer = loadedGLFWVersion();
        if ( (glfwVer == GLFWSupport.glfw30) ||
             (glfwVer == GLFWSupport.glfw31) ||
             (glfwVer == GLFWSupport.glfw32) )
        {
            writeln("GLFW - Graphics Library FrameWork - Version ", glfwVer, " successfully loaded");
        } 
        else
        {
            writeln("An unexpected version of GLFW - Graphics Library FrameWork - was loaded");
            exit(0);
        }
    }
    else
    {
        writeln("No version of the GLFW library was loaded");
        exit(0);       
    }

    if (glfwInit() == 0)
        throw new Exception("glfwInit failed");
}
