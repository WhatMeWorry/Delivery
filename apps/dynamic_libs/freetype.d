
module dynamic_libs.freetype;

import std.stdio : writeln, writefln;
import core.stdc.stdlib : exit;

public import bindbc.freetype;


                           // default arguments 
void load_FreeType_Library(string calledFuncName = __FUNCTION__, 
                           string calledFile = __FILE_FULL_PATH__, 
                           int calledLine = __LINE__)
{
    // ftSupport is FTSupport.ft26, ft27, ... or ft210 depending on what version was requested in the dub.sdl file.
    // FTSupport is a superset of glSupport where FTSupport also has the bad library and no library values
 
    // ftSupport is initialized at compile time from the dub.sdl freeType version command

    writeln("The dub.sdl file of this project expects FreeType version ", ftSupport);

    writeln("Calling Function: ", calledFuncName, " calling file: ", calledFile, " calling line: ", calledLine);

 
	
    version(Windows) 
    {
	
        writefln("Inside function %s at file %s line %s",__FUNCTION__, __FILE_FULL_PATH__, __LINE__); 	
	
        loadFreeType("./../../windows/dynamic_libraries/freetype.dll");
    }	
    /+
    immutable FTSupport ftLib = loadFreeType();

    writeln("FreeType version detected on this system is ", ftLib);

    if (ftLib == FTSupport.noLibrary) 
    {
        writeln("No FreeType library was detected");
        exit(0);        
    }
    else if (ftLib == FTSupport.badLibrary) 
    {
        writeln("One or more symbols failed to load. The likely cause is that this FreeType library");
        writeln("loaded has a lower version than bindbc-freetype was configured for");       
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
    +/	
}
