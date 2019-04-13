
module derelict_libraries;

//public import derelict.glfw3;
public import bindbc.glfw;       
public import bindbc.opengl;
public import bindbc.freeimage;
public import bindbc.freetype;
public import derelict.util.exception;   // needed for the return type enum ShouldThrow.
public import derelict.util.sharedlib;
public import derelict.assimp3.assimp;
//public import derelict.sdl2.sdl;
public import bindbc.sdl;
//public import derelict.sdl2.mixer;
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




void load_openGL_Library()
{
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
}



void load_FreeImage_Library()
{
    // fiSupport is initialized at compile time from the dub.sdl freeimage specification

     writeln("The dub.sdl file of this project expects FreeImage version ", fiSupport);

    immutable FISupport fiLib = loadFreeImage();

    writeln("FreeImage version detected on this system is ", fiLib);

    if (fiLib == fiSupport.fi317)
    {
        writeln("Freeimage Version 3.17.0 successfully loaded");
    } 
    else if (fiLib == fiSupport.fi318)
    {
        writeln("Freeimage Version 3.18.0 successfully loaded");
    }  
    else if (fiLib == FISupport.noLibrary) 
    {
        writeln("No FreeImage shared library was detected");
        exit(0);        
    }
    else if (fiLib == FISupport.badLibrary) 
    {
        writeln("One or more symbols failed to load. The likely cause is that the shared");
        writeln("library has a lower version than bindbc-freeimage was configured for");       
        exit(0);                
    }
}




void load_FreeType_Library()
{
    // ftSupport is FTSupport.ft26, ft27, ... or ft210 depending on what version was requested in the dub.sdl file.
    // FTSupport is a superset of glSupport where FTSupport also has the bad library and no library values
 
    // ftSupport is initialized at compile time from the dub.sdl freeType version command

    writeln("The dub.sdl file of this project expects FreeType version ", ftSupport);

    immutable FTSupport ftLib = loadFreeType();

    writeln("FreeImage version detected on this system is ", ftLib);

    if (ftLib == FTSupport.noLibrary) 
    {
        writeln("No FreeType library was detected");
        exit(0);        
    }
    else if (ftLib == FTSupport.badLibrary) 
    {
        writeln("One or more symbols failed to load. The likely cause is that this FreeType library");
        writeln("loaded has a lower version than bindbc-freeimage was configured for");       
        exit(0);                
    }
    else if (ftLib != ftSupport) 
    {
        writeln("FreeType version ", ftSupport, " was requested in the dub.sdl file. Version ", ftLib, " was loaded" );      
        exit(0);                
    }
    else
    {
        writeln("FreeType version ", ftLib, " was successfully loaded");
    }   
}



void load_SDL_Library()
{
    // sdlSupport is SDLSupport.sdl200, sdl201, ... or sdl209 depending on what version was specified in the dub.sdl file.
    // SDLSupport is a superset of sdlSupport where SDLSupport also has the bad library and no library values

    // ftSupport is initialized at compile time from the dub.sdl freeType version command

    writeln("The dub.sdl file of this project requests FreeType version ", sdlSupport);

    immutable SDLSupport sdlLib = loadSDL();

    writeln("SDL version detected on this system is ", sdlLib);

    if (sdlLib == SDLSupport.noLibrary) 
    {
        writeln("No SDL library was detected");
        exit(0);        
    }
    else if (sdlLib == SDLSupport.badLibrary) 
    {
        writeln("One or more symbols failed to load. The likely cause is that this SDL library");
        writeln("loaded has a lower version than bindbc-sdl was configured for");       
        exit(0);                
    }
    else if (sdlLib != sdlSupport) 
    {
        writeln("SDL version ", sdlSupport, " was requested in the dub.sdl file. Version ", sdlLib, " was loaded" );      
        exit(0);                
    }
    else
    {
        writeln("SDL version ", sdlLib, " was successfully loaded");
    }   
}


void load_SDL_Mixer_Library()
{
    // sdlMixerSupport is SDLMixerSupport.sdlMixer200, sdlMixer201 or sdlMixer202 depending on what version was specified in the dub.sdl file.
    // SDLMixerSupport is a superset of sdlSupport where SDLMixerSupport also has the bad library and no library values

    writeln("The dub.sdl file of this project requests SDL Mixer version ", sdlMixerSupport);

    immutable SDLMixerSupport  sdlMixLib = loadSDLMixer();

    writeln("SDL Mixer version detected on this system is  ", sdlMixLib);

    if (sdlMixLib == SDLMixerSupport.noLibrary) 
    {
        writeln("No SDL_Mixer library was detected");
        exit(0);        
    }
    else if (sdlMixLib == SDLMixerSupport.badLibrary) 
    {
        writeln("One or more symbols failed to load. The likely cause is that this SDL_Mixer library");
        writeln("loaded has a lower version than bindbc-sdl was configured for");       
        exit(0);                
    }
    else if (sdlMixLib != sdlMixerSupport) 
    {
        writeln("SDL_Mixer version ", sdlMixerSupport, " was requested in the dub.sdl file. Version ", sdlMixLib, " was loaded" );      
        exit(0);                
    }
    else
    {
        writeln("SDL_Mixer version ", sdlMixLib, " was successfully loaded");
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

    //DerelictSDL2Mixer.load();

    DerelictASSIMP3.missingSymbolCallback = &myMissingSymCallBackASSIMP3;

   
    DerelictASSIMP3.load();   // Load the Assimp3 library.

    // Now Assimp3 functions can be called.
}
