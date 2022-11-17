
/+
..\duball.exe run --compiler=ldc2 --arch=x86_64 --force
+/

/+
    defined in std.system

    Information about the target operating system, environment, and CPU.

    enum OS
    {
        win32 = 1, /// Microsoft 32 bit Windows systems
        win64,     /// Microsoft 64 bit Windows systems
        linux,     /// All Linux Systems
        osx,       /// Mac OS X
        freeBSD,   /// FreeBSD
        netBSD,    /// NetBSD
        solaris,   /// Solaris
        android,   /// Android
        otherPosix /// Other Posix Systems
    }


    Defined in Language

    Version identifiers do not conflict with other identifiers in the code, they
    are in a separate name space. Predefined version identifiers are global.
    Predefined Version Identifiers
    Version Identifier    Description
    ------------------    ---------------------
    Windows               Microsoft Windows systems
    Win32                 Microsoft 32-bit Windows systems
    Win64                 Microsoft 64-bit Windows systems
    linux                 All Linux systems
    OSX                   Mac OS X
  +/

module duball;

// Procedure for using this tool to create a new project
/+

cd to D:\projects
D:\projects>dir
 Volume in drive D is Delivery
 Volume Serial Number is 3625-0128

 Directory of D:\projects

10/24/2016  06:11 PM    <DIR>          .
09/21/2016  05:38 PM    <DIR>          ..
10/11/2016  11:48 AM            14,021 duball.d
09/20/2016  05:18 PM    <DIR>          colors
09/21/2016  05:20 PM           391,192 duball.o
09/21/2016  05:20 PM         2,138,672 duball
09/07/2016  05:48 PM         2,137,816 dubmac
09/07/2016  05:53 PM         1,942,656 dublin
09/23/2016  06:33 PM           618,670 duball.obj
10/16/2016  03:22 PM    <DIR>          01_01_hello_window
09/23/2016  06:33 PM           829,952 duball.exe
11/13/2016  04:30 PM    <DIR>          common
09/30/2016  11:37 AM    <DIR>          deimos
10/16/2016  03:23 PM    <DIR>          01_04_textures
10/16/2016  03:23 PM    <DIR>          01_05_transformations
10/16/2016  03:24 PM    <DIR>          01_06_coordinate_systems

Pick out a unique name for the new project:  in this case 02_02_basic_lighting

D:\projects>duball.exe init 02_02_basic_lighting
or Git Bash
/c/Users/kheaser/GitHub/Delivery/projects (master)
$ ./duball.exe init 02_02_basic_lighting


Package recipe format (sdl/json) [json]: sdl
Name [02_02_basic_lighting]:
Description [A minimal D application.]:
Author name [kheaser]:
License [proprietary]:
Copyright string [Copyright ┬⌐ 2016, kheaser]:
Add dependency (leave empty to skip) []:
Successfully created an empty project in 'D:\projects\02_02_basic_lighting'.
Package sucessfully created in 02_02_basic_lighting
myapp exited with code 0

cd D:\projects>cd 02_02_basic_lighting

Edit the dub.sdl (add the dependencies and sourceFiles).  Just copy a previous one.
+/

/+
Windows only looks in certain directories for a DLL. The following search
order is used:
1) The directory where the executable module for the current process is located.
2) The current directory.
3) The Windows system directory. The GetSystemDirectory function retrieves the path of this directory.
4) The Windows directory. The GetWindowsDirectory function retrieves the path of this directory.
5) The directories listed in the PATH environment variable.
Note: The LIBPATH environment variable is not used.
+/

/+
Tested on lenovo ThinkCentre   9/20/2016
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
DISTRIB_RELEASE=16.04
DISTRIB_CODENAME=xenial
DISTRIB_DESCRIPTION="Ubuntu 16.04.1 LTS"

Tested on lenovo ThinkCentre   9/20/2016
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Windows 8.0 64 bit - 64 bit operating system, x64 based processor

+/

/+

NOTE: MUST HAVE CONNECTIONS TO INTERNET

-m64   Compile a 64 bit executable. The generated object code is in MS-COFF and is meant to be  used with the Microsoft Visual Studio 10 or later compiler.

Build duball on ========== Windows ==========
cd to where duball.d is.
$ ldc2 -m64 duball.d

cd to one of the apps 
/01_01_hello_window$ .\..\duball run --arch=x86_64 --compiler=ldc2 --verbose --force

Build duball on ========== Linux ==========
cd to where duball.d is.
$ ldc2 -m64 duball.d

cd to one of the apps 
/01_01_hello_window$ ./../duball run --arch=x86_64 --compiler=ldc2 --verbose --force

Build duball on ========== OSX ==========
cd to where duball.d is.
$ ldc2 -m64 duball.d

cd to one of the apps 
/01_01_hello_window$ ./../duball run --arch=x86_64 --compiler=ldc2 --verbose --force

Observation: when moving the flash drive from Linux to Windows, lots of files are
marked as Read-only. Right click on the file(s) and go into properties an unclick Read-only

+/

/+
So remember:

• the SysWOW64 folder is intended for 32-bit files only
• the System32 folder is intended for 64-bit files only

• always install a 32-bit program into the Program Files (x86) folder
• always install a 64-bit program into the Program Files folder
SysWOW64 and Program Files (x86) are special folders that only exists on 64-bit Windows and they are intended to store 32-bit binary files. In the folder names there are the "strange" character combinations WOW64 and x86 included. These character combinations have a meaning and we will explain it below:

• WOW64 is a shortening for ”Windows on Windows 64-bit” (can be read as "Windows 32-bit on Windows 64-bit"). It's a emulator that allows 32-bit Windows-based applications to run seamlessly on 64-bit Windows. A compatibility layer is used as an interface between the 32-bit program and the 64-bit operating system.

 • x86 is the name of a processor architecture from Intel that handles 32 bit instruction sets. The x86 term have been used for a very long time and in the beginning it was used as a general term to refer to Intel 16/32 bit processors with names such 8086, 80186, 80286, 80386 etc. But since the release of the 80386 processor, the first real 32 bit processor, the term x86 have been used to refer to 32-bit processors that have an instruction set that is compatible with the old 80386 processor.
+/

/+
duball.d must be built (compiled) separately for Windows, MacOS,
and Linux

It is not possible to use a common executable that could be run on both Windows and Linux
because the PE (Windows) and ELF (Linux) binary executable formats are totally different.
Also windows ends all it executables with the .exe extension.

+/


import std.stdio;
import std.system;  // defines enum OS     OS os = OS.win64;
import std.algorithm.searching : endsWith, canFind;
import std.algorithm.iteration : splitter;
import std.process : Config, environment, executeShell, execute, spawnShell, spawnProcess, wait;
import std.string;
import std.file : getcwd;
import std.exception: enforce;


/+
where /R c:\ dmd
c:\Users\kheaser\OneDrive - Ela Area Public Library\Documents\GitHub\Delivery\windows\compilers_and_utilities\dmd.exe
c:\Users\kheaser\OneDrive - Ela Area Public Library\Documents\GitHub\Delivery\windows\compilers_and_utilities\D\dmd2\windows\bin\dmd.exe
c:\Users\kheaser\OneDrive - Ela Area Public Library\Documents\GitHub\Delivery\windows\compilers_and_utilities\D\dmd2\windows\bin64\dmd.exe
c:\Users\kheaser\OneDrive - Ela Area Public Library\Downloads\dmd2\windows\bin\dmd.exe
c:\Users\kheaser\OneDrive - Ela Area Public Library\Downloads\dmd2\windows\bin64\dmd.exe

+/

// Class std.process.environment
// Manipulates environment variables using an associative-array-like interface.
// This class contains only static methods, and cannot be instantiated.

auto findExecutable(string exec)
{
    version(linux)
        string command = "whereis ";  // Linux uses whereis
    else version(Windows)
    {
        string command = `where /R c:\ `;    // Windows cmd shell uses where - does not work with Powershell		
    }
    else version(OSX)
        string command = "which ";    // Mac uses which

    auto at = executeShell(command ~ exec);
    enforce(at.status == 0, exec, " is not found on this system");
 
    return at;
}


auto splitUpPaths(string envPath)
{
    version(Windows)
        auto paths = envPath.splitter(';');   // Windows uses semi-colons;
    else version(linux)
        auto paths = envPath.splitter(':');   // Linux uses colon separator
		
    return paths;
}



void main(char[][] args)
{
    // here we use the system provided enum and the variable os defined as
    // immutable OS os;  // The OS that the program was compiled for.

    foreach (i, arg; args)
    {
        //writeln("duball arg ", i, " *", arg, "*");
    }

    string progName = args[0].idup;  // get the command that called this program
                                     // (should be duball.exe or duball )
    writeln("the command that called this program (duball.exe) was: ", progName);
						
    version(linux)
    {

    }
    else version(Windows)
    {
        if ((os != OS.win64) | (progName != r"..\duball.exe"))
            writeln("FAILURE: os = ", os, "  progName = ", progName);
    }
    else version(OSX)
    {

    }

    // Check that dmd is installed on this system 
	
    auto found = findExecutable("dmd");
    writeln("\n", "dmd", " was found at: ", found.output);  
		
    // Check that dub is installed on this system

    //found = findExecutable("dub");
    //writeln("\n", "dub", " was found at: ", found.output);      


    //auto paths = splitUpPaths(envPath);

    version(linux)
    {
        // ldc2 and dub are automatically placed in default user binary directories at install time
        // so paths don't need to be modified to run these two

        // This error appeared on Antergos Linux
        // object.Exception@std/process.d(3171): Environment variable not found: LD_LIBRARY_PATH
 
        environment["LD_LIBRARY_PATH"] = `./../../linux/dynamiclibraries:/ignore/this/one:`;        

    } else version(Win64)
    {
        // Make sure the directory path to DMD2 and Optlink is listed in your PATH environment variable. 
        // This directory is usually C:\DMD\dmd2\windows\bin on Windows.
	
        // ldc2 and dub are automatically placed in C:\ldc2\bin whose path is 
        // automatically added to $PATH

        string dynamicPath = `.\..\..\windows\dynamiclibraries;`;    // needed for glfw3.dll
        //envPath = dynamicPath ~ envPath;  // Prepend dynamiclibraries path to $PATH
        //environment["PATH"] = envPath;  // Update with new       

        /+ Microsoft quote "LIB, if defined. The LINK tools uses the LIB path when
           searching for an object or library (example, libucrt.lib) +/

        // This error appeared on Windows 10, 
        // object.Exception@std\process.d(3171): Environment variable not found: LIB
        // when commented out the following line: 
        environment["LIB"] = `.\path\to\nowhere`;

        //environment["DFLAGS"] = `-I..\  -I..\common  -I..\common_game`;    

    } else version(OSX)
    {
     
        environment["LD_LIBRARY_PATH"] = `./../../macos/dynamiclibraries`; 
        environment["DYLD_LIBRARY_PATH"] = `./../../macos/dynamiclibraries`;      
    }

    //string newPathVar = compilerPath ~ dubPath ~ envPath;

    //environment["PATH"] = newPathVar;  // Update the PATH environment


    /+
    paths = splitUpPaths(envPath);
    writeln("\n","The PATH env variable now has paths:");
    foreach(path; paths)
    {
        writeln("   ",path);
    }
    +/

    args[0] = "dub".dup;  // overwrite dubwin, dubmac, or dublin with the generic dup command
	
    string currentDirectory = getcwd();	
	
	//writeln("currentDirectory = ", currentDirectory);

    /+
    By default, the child process inherits the environment of the parent process, along
    with any additional variables specified in the env parameter. If the same variable
    exists in both the parent's environment and in env, the latter takes precedence.
    +/
	
	string absolutePath = currentDirectory ~ `\..\..\windows\compilers_and_utilities\dmd2\windows\bin64\dub.exe`;
	
	args[0] = absolutePath.dup;
	
    writeln("FULL COMMAND LINE = *", args, "*");	
	
    foreach(arg; args)
    {
        //writeln("<<", arg, ">>");
    }

    auto pid = spawnProcess(args,
                            std.stdio.stdin,
                            std.stdio.stdout,
                            std.stdio.stderr,
                            null,
                            Config.none,
                            null);
    scope(exit)
    {
        auto exitCode = wait(pid);
        writeln(progName, " exited with code ", exitCode);
    }


 

}
