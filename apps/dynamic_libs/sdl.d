
module dynamic_libs.sdl;

public import bindbc.sdl;


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
