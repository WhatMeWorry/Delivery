
module dynamic_libs.freeimage;

public import bindbc.freeimage;

import std.stdio;
import core.stdc.stdlib;  // : exit


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




