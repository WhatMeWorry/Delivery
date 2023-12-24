
module dynamic_libs.assimp;

//public import bindbc.assimp;
public import derelict.assimp3.assimp;

public import derelict.util.exception;   // needed for the return type enum ShouldThrow.
public import derelict.util.sharedlib;


// import path[5] = ..\..\..\AppData\Local\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\source
//public import assimp3.assimp;   // ..\dynamic_libs\assimp.d(6,15): Error: module `assimp` is in file 'assimp3\assimp.d' which cannot be read

import std.stdio;
import core.stdc.stdlib : exit;



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


// bindbc-assimp is no longer being actively developed and required an ealier version
// of bindbc-loader which conflicted with bindbc-opengl and bindbc-glfw. Had to revert to Dereliect-assimp

void load_Assimp_Library()
{
    // Derelict is absolete but bindbc.assimp is not ready for prime time.

    DerelictASSIMP3.missingSymbolCallback = &myMissingSymCallBackASSIMP3;

    //DerelictASSIMP3.load();   // Load the Assimp3 library.

    // From github
    //    Lansatac/sandbox-engine
    //       source/assimp/AssImpMeshDataRepository.d

    
    version(Windows)
    {
        import std.file : getcwd;
        writeln("present working subdirectory: ", getcwd());
		// C:\Users\kheaser\Documents\GitHub\Delivery\apps\02_03_lighting_materials
		
        writefln("Inside function %s at file %s line %s",__FUNCTION__, __FILE_FULL_PATH__, __LINE__); 		

        import std.file;
        // Iterate the current directory in breadth
        foreach (string name; dirEntries("./../../windows/dynamic_libraries", SpanMode.breadth))
        {
             writeln(name);
        }
	
        DerelictASSIMP3.load("./../../windows/dynamic_libraries/assimp.dll");
    }
    else
    {
        DerelictASSIMP3.load();
    }
    

    // From Githup    
    //     mlizard32/Glib
    //         src/Glib/System/System.d

    //  pragma(lib, "DerelictASSIMP3.lib");
    //  DerelictASSIMP3.load("..//..//Libs//Assimp32.dll");

    /+
    version(Windows) 
    {
        loadAssimp("./../../../windows/dynamiclibraries/assimp.dll");
    }
    +/
	
    // This version attempts to load the Assimp shared library using well-known variations
    // of the library name for the host system.

    /*
    immutable AssimpSupport ret = loadAssimp();

        code for loadAssimp trys to load 

            version(Windows) { const(char)[][1] libNames = [ "Assimp5.dll"]; }

    if (ret == AssimpSupport.noLibrary) 
    {
        throw new Exception("Assimp shared library failed to load.");
    }
    if (AssimpSupport.badLibrary) 
    {
        throw new Exception("One or more Assimp symbols failed to load. Likely cause is that shared 
                             library is for a lower version than bindbc-assimp was configured for.");        
    }
    */


}

