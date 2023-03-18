import std.stdio;
import std.file; // exists
import bindbc.freeimage;
import bindbc.loader;
import bindbc.glfw;

void main()
{
	//writeln("In main() function for 00_03_freeimage_debug project");

    //writeln("__MODULE__ returns ",          __MODULE__);
    //writeln("__FILE__ returns ",            __FILE__);	
    //writeln("__FILE_FULL_PATH__ returns ",  __FILE_FULL_PATH__);	
    //writeln("__LINE__ returns ",            __LINE__);	
    //writeln("__FUNCTION__ returns ",        __FUNCTION__);
    //writeln("__PRETTY_FUNCTION__ returns ", __PRETTY_FUNCTION__);	


    //writeln("getcwd() returns ", getcwd());
    //writeln("files in this directory are: ", dirEntries("", SpanMode.shallow) );


	
	// bool exists(R)(R name)
	
    // if (exists(__FILE_FULL_PATH__))          // WORKS
	// if (exists(getcwd() ~ `source\app.d`))	// FAILS
    // if (exists(getcwd() ~ `\source\app.d`))	// WORKS - must prepend dir separator 
	// if (exists(`\source\app.d`))             // FAILS
	/+
	if (exists(`source\app.d`))              // WORKS - must not prepend the dir separator
    {
        writeln("the file app.d does exist");
    }
    else
    {
        writeln("the file main.d does not exist");
    }	
    +/

    /+	
    version(Windows) setCustomLoaderSearchPath("libs");

    if (exists(`libs\FreeImage.dll`))              
        writeln(`the file libs\FreeImage.dll DOES exist`);
    else
        writeln(`the file libs\FreeImage.dll NOT FOUND`);

	FISupport ret = loadFreeImage(`libs\FreeImage.dll`);
    writeln("ret = ", ret);			
    +/

    if (exists("FreeImage.dll"))            
        writeln("the file FreeImage.dll DOES exist");
    else
        writeln("the file FreeImage.dll NOT FOUND");
	
    FISupport ret = loadFreeImage(`FreeImage.dll`);
    writeln("ret = ", ret);
	
    ret = loadFreeImage();
    writeln("ret = ", ret);
		
    /+
    if (exists(`libs\glfw3.dll`))              
        writeln(`the file libs\glfw3.dll DOES exist`);
    else
        writeln(`the file libs\glfw3.dll NOT FOUND`);

    GLFWSupport retGLFW = loadGLFW(`libs\glfw3.dll`);
    writeln("retGLFW = ", retGLFW);
	+/
	
    if (exists("glfw3.dll"))            
        writeln("the file glfw3.dll DOES exist");
    else
        writeln("the file glfw3.dll NOT FOUND");

    GLFWSupport retGLFW = loadGLFW("glfw3.dll");
    writeln("retGLFW = ", retGLFW);

    retGLFW = loadGLFW();
    writeln("retGLFW = ", retGLFW);


	
}
