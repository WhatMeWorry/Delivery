
module derelict_libraries;

public import derelict.glfw3;          // GLFW
public import derelict.opengl3.gl3;
public import derelict.freeimage.freeimage;
public import derelict.freetype.ft;
public import derelict.openal.al;
public import derelict.util.exception;   // needed for the return type enum ShouldThrow.
public import derelict.util.sharedlib;
public import derelict.fmod.fmod;
public import derelict.assimp3.assimp;


import std.stdio;



ShouldThrow myMissingSymCallBackFI( string symbolName )
{
    if (symbolName == "FreeImage_JPEGTransform"       ||     // Linux libfreeimage.so 
        symbolName == "FreeImage_JPEGTransformU"      ||
        symbolName == "FreeImage_JPEGCrop"            ||
        symbolName == "FreeImage_JPEGCropU"           ||
        symbolName == "FreeImage_JPEGTransformFromHandle" ||
        symbolName == "FreeImage_JPEGTransformCombined"   ||
        symbolName == "FreeImage_JPEGTransformCombinedU"  ||
        symbolName == "FreeImage_JPEGTransformCombinedFromMemory"
        
       )
    {
       return ShouldThrow.No;
    }
    else
    {
        return ShouldThrow.Yes;
    }
}


ShouldThrow myMissingSymCallBackFT( string symbolName )
{
    if (symbolName == "FT_Stream_OpenBzip2"                     ||  // Windows libfreetype-6.dll
	    symbolName == "FT_Get_CID_Is_Internally_CID_Keyed"      ||
	    symbolName == "FT_Get_CID_From_Glyph_Index"             ||		
	    symbolName == "FT_Get_CID_Registry_Ordering_Supplement"
       )
    {
       return ShouldThrow.No;
    }
    else
    {
        return ShouldThrow.Yes;
    }
}


ShouldThrow myMissingSymCallBackFmod( string symbolName )
{
    if (symbolName == "FMOD_System_GetChannelsReal"        ||  // Windows fmod.dll
	    symbolName == "FMOD_Channel_OverridePanDSP"        ||
	    symbolName == "FMOD_ChannelGroup_OverridePanDSP"	
       )
    {
       return ShouldThrow.No;
    }
    else
    {
        return ShouldThrow.Yes;
    }
}


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

//auto load_libraries()
void load_libraries()
{
    DerelictGLFW3.load();   // must be loaded before OpenGL so a context can be created
    //versions(Windows)
	    //DerelictGLFW3_loadWindows();   // New
	
	writeln("GLFW3 library loaded");
	
    if (glfwInit() == 0) 
        throw new Exception("glfwInit failed");
		
    // Set all the required options for GLFW
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwWindowHint(GLFW_RESIZABLE, GL_TRUE);		
		
    // Load Open Graphics Library
	
    DerelictGL3.load();     // Load OpenGL versions 1.0 and 1.1
	
    // Create an OpenGL context with another library (in this case, GLFW 3)
	
	//auto window = glfwCreateWindow(800, 600, "Context Window", null, null);
    auto window = glfwCreateWindow(800, 600, "Context Window", null, null);	

    if (!window)
        throw new Exception("Window Creation Failed.");

    glfwMakeContextCurrent(window); 
	
    DerelictGL3.reload();   // Load OpenGL versions 1.2+ 
	
	glfwDestroyWindow(window);

	writeln("OpenGL library loaded");
    
	// Set the callback before calling load
    DerelictFI.missingSymbolCallback = &myMissingSymCallBackFI;    
    DerelictFI.load();      // Load the FreeImage library	

	writeln("FreeImage library loaded");
	
	// Set the callback before calling load
    DerelictFT.missingSymbolCallback = &myMissingSymCallBackFT;
    DerelictFT.load();	    // Load the FreeType library	
	
    int v0,v1,v2;
    FT_Library library;
	
    if (FT_Init_FreeType(&library))  // 0 means success
    {
        write("Could not initialize FreeType Library");
    }
	
    FT_Library_Version(library, &v0, &v1, &v2);
    writeln("FreeType library loaded version = ", v0, ".", v1, ".", v2);
		
    DerelictAL.load();      // Load the OpenAL library
	
    writeln("OpenAL library loaded"); 

    // Load the Fmod library.
	
	// Set the callback before calling load
    DerelictFmod.missingSymbolCallback = &myMissingSymCallBackFmod;
    DerelictFmod.load();
	
    // Load the Fmod studio library.
    //DerelictFmodStudio.load();

    // Now Fmod functions can be called.
	
    writeln("FMOD library loaded"); 

    DerelictASSIMP3.missingSymbolCallback = &myMissingSymCallBackASSIMP3;	
	
    // Load the Assimp3 library.
    DerelictASSIMP3.load();

    // Now Assimp3 functions can be called.
	
    writeln("DerelictASSIMP3 library loaded"); 
 	
	//return window;
}	
	
	













