
module dynamic_libs.freetype;

public import bindbc.freetype;



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
