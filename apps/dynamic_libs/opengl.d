
module dynamic_libs.opengl;

public import bindbc.opengl;

import std.stdio;
import core.stdc.stdlib : exit;
import dynamic_libs.glfw;

void load_openGL_Library()
{

   // Create an OpenGL context with another library (in this case, GLFW 3)

    auto tempContextWindow = glfwCreateWindow(100, 100, "Temporary Context Window", null, null);

    writeln("tempContextWindow = ", tempContextWindow);

    if (!tempContextWindow)
    {
        throw new Exception("tempContextWindow Creation Failed.");
    }

    glfwMakeContextCurrent(tempContextWindow);

    //load_openGL_Library();


    // maybe make this an embedded function within a function?????

    // glSupport is GLSupport.gl46 , gl45, ... or gl1 depending on what version was assigned in the dub.sdl file.
    // GLSupport is a superset of glSupport where GLSupport also has the bad library, no library and no context

    // glSupport is initialized at compile time from the bindbc/dub.sdl OpenGL specification

    writeln("The dub.sdl file of this project expects OpengGL version ", glSupport);

    immutable GLSupport glLib = loadOpenGL();

    writeln("OpenGL version detected on this system is ", glLib);

    if (glLib == GLSupport.noLibrary) 
    {
        writeln("No openGL library was detected");
        exit(0);        
    }
    else if (glLib == GLSupport.badLibrary) 
    {
        writeln("One or more symbols failed to load. The likely cause is that this openGL");
        writeln("library has a lower version than bindbc-freeimage was configured for");       
        exit(0);                
    }
    else if (glLib == GLSupport.noContext) 
    {
        writeln("A context must be created before openGL can be loaded");      
        exit(0);                
    }
    else if (glLib != glSupport) 
    {
        writeln("OpenGL version ", glSupport, " was requested in the dub.sdl file. Version ", glLib, " was loaded" );      
        exit(0);                
    }
    else
    {
        writeln("OpenGL version ", glLib, " was successfully loaded");
    } 



    glfwDestroyWindow(tempContextWindow);


}

