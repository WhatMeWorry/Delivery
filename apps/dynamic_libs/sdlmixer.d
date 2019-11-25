
module dynamic_libs.sdlmixer;

public import bindbc.sdl.mixer;



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
