//import std.stdio;
//import std.file; // exists, isDir, getcwd, dirEntries, SpanMode, chdir;
//import bindbc.freeimage;
//import bindbc.loader;

import std.stdio: writeln;
import std.string: toStringz;
import core.sys.windows.windows : LoadLibraryA, GetLastError;

void main()
{
    string[] DLLs = [ "assimp.dll", "fmod.dll", "freetype.dll", "glfw3.dll", 
                      "OpenAL32.dll", "SDL2.dll", "SDL2_mixer.dll", "FreeImage.dll" ];
	
    foreach(dll; DLLs)
    {
        void *ptr = LoadLibraryA(toStringz(dll));
		writeln("GetLastError = ", GetLastError());
        if (ptr)
            writeln("calling LoadLibraryA with ", dll, " ptr is set");   
        else
            writeln("calling LoadLibraryA with ", dll, " ptr is NULL");		
    }
}
	
/+	
C:\Users\Admin\Documents\GitHub\Delivery\apps\00_03_freeimage_debug>app.exe
calling LoadLibraryA with assimp.dll ptr is NULL
calling LoadLibraryA with fmod.dll ptr is set
calling LoadLibraryA with freetype.dll ptr is set
calling LoadLibraryA with glfw3.dll ptr is set
calling LoadLibraryA with OpenAL32.dll ptr is set
calling LoadLibraryA with SDL2.dll ptr is set
calling LoadLibraryA with SDL2_mixer.dll ptr is set
calling LoadLibraryA with FreeImage.dll ptr is NULL
	
	
C:\Users\Admin\Documents\GitHub\Delivery\apps\00_03_freeimage_debug>dir

03/22/2023  01:45 PM             3,116 app.d
03/22/2023  01:46 PM           681,984 app.exe

03/06/2023  04:25 PM         3,805,184 assimp.dll
03/06/2023  04:25 PM         1,721,344 fmod.dll
07/31/2018  01:23 PM         6,942,208 FreeImage.dll
03/06/2023  04:25 PM           832,512 freetype.dll
03/06/2023  04:25 PM           216,576 glfw3.dll
03/06/2023  04:25 PM           122,904 OpenAL32.dll
03/06/2023  04:25 PM         1,220,096 SDL2.dll
03/06/2023  04:25 PM           143,872 SDL2_mixer.dll
+/
	
	/+
    string Dstring = "FreeImage.dll"; 
	
    //string Dstring = "glfw3.dll";
	
    void *ptr = LoadLibraryA(toStringz(Dstring));
	
    if (!ptr)
        writeln("ptr is null after call to LoadLibraryA");
    else
        writeln("ptr is set to something");
	+/


/+	
	

    //writeln("__MODULE__ returns ",          __MODULE__);
    //writeln("__FILE__ returns ",            __FILE__);	
    writeln("__FILE_FULL_PATH__ returns ",  __FILE_FULL_PATH__);	
    //writeln("__LINE__ returns ",            __LINE__);	
    //writeln("__FUNCTION__ returns ",        __FUNCTION__);
    //writeln("__PRETTY_FUNCTION__ returns ", __PRETTY_FUNCTION__);	


    writeln("getcwd() returns ", getcwd());
    writeln("files in this directory are: ", dirEntries("", SpanMode.shallow) );


	
	// bool exists(R)(R name)
	
    // if (exists(__FILE_FULL_PATH__))          // WORKS
	// if (exists(getcwd() ~ `source\app.d`))	// FAILS
    // if (exists(getcwd() ~ `\source\app.d`))	// WORKS - must prepend dir separator 
	// if (exists(`\source\app.d`))             // FAILS
	if (exists(`source\app.d`))              // WORKS - must not prepend the dir separator
    {
        writeln("the file app.d does exist");
    }
    else
    {
        writeln("the file main.d does not exist");
    }	

	if (exists(`libs\FreeImage.dll`))              
        writeln(`the file libs\FreeImage.dll DOES exist`);
    else
        writeln(`the file libs\FreeImage.dll NOT FOUND`);	

	if (exists("FreeImage.dll"))            
        writeln("the file FreeImage.dll DOES exist");
    else
        writeln("the file FreeImage.dll NOT FOUND");

	
    //FISupport ret = loadFreeImage("FreeImage.dll");
    //writeln("ret = ", ret);
    FISupport ret;
	//ret = loadFreeImage();
    //writeln("ret ==============================> ", ret);
	
	//version(Windows) setCustomLoaderSearchPath("libs");
	
	//ret = loadFreeImage(`libs\FreeImage.dll`);
	ret = loadFreeImage();
    writeln("ret ====> ", ret);
	
	//ret = loadFreeImage(`libs/FreeImage.dll`);
    //writeln("ret = ", ret);		
	
    if(ret != fiSupport) 
	{
        if(ret == FISupport.noLibrary) 
		{
            writeln("No Library");
        }
        else 
		{
		    if(FISupport.badLibrary) 
            {
                writeln("Bad Library");
            }
			else
			{
			    writeln("ret = ", ret);
			}
		}
    }
	else
    {
        writeln("ret is ", ret);
		writeln("fiSupport is ", fiSupport);	
	}


    version(Windows) setCustomLoaderSearchPath(null);


+/
	

