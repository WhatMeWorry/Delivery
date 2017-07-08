
/+
..\duball.exe run --verbose --arch=x86_64 --force
+/

module duball;

// We are using Visual Studio 2015 which is presently the most current

//version(Windows)
    //pragma(lib, `.\..\Windows\Windows Kits\10\Lib\10.0.14393.0\ucrt\x64\libucrt`);
    //pragma(lib, `C:\Program Files (x86)\Windows Kits\10\Lib\10.0.14393.0\ucrt\x64\libucrt.lib`);

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
Executables only look in certain directories for a DLL. Windows will search the following
locations in order for your DLL:
1) the current directory that the executable is running from
2) the Windows system directory (<Windows>\System32)
3) any paths specified in the PATH environmental variable
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

NOTE:  MUST HAVE CONNECTIONS TO INTERNET

-m64   Compile a 64 bit executable. The generated object code is in MS-COFF and is meant to be  used with the Microsoft Visual Studio 10 or later compiler.

Build duball on ========== Windows ==========
..\Windows\D\dmd2\windows\bin\dmd.exe -m64 duball.d    // Always assume 64 bit (for simplicity)
Build Project on Windows
E:\projects\01_01_hello_window>..\duball.exe run --verbose --arch=x86_64 --force

Build duball on ========== Linux ==========
./../Linux/dmd-2.071.0/linux/bin64/dmd duball.d
Build Project on Linux
/projects/01_01_hello_window>./../duball build --verbose --arch=x86_64 --force

Build duball on ========== OSX ==========
SOME_MAC:projects someuser$ sudo ./../MacOS/D/osx/bin/dmd -m64 duball.d
enter
space, space, space...
agree
Build duball on OSX
SOME_MAC:projects/01_01_hello_window someuser$ ./../duball build --verbose --arch=x86_64 --force

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
duball.d will be built for
1) Windows (64 bit only) and renamed dubwin.exe
2) MacOS and renamed dubmac
3) Linux and renamed dublin

It is not possible to use a common executable that could be run on both Windows and Linux
because the PE (Windows) and ELF (Linux) binary executable formats are totally different.
Also windows ends all it executables with the .exe extension.

+/

// GNU bash, version 3.2.57(1)-release (x86_64-apple-darwin15)


import std.stdio;
import std.system;  // defines enum OS     OS os = OS.win64;
import std.algorithm.searching : endsWith, canFind;
static import std.algorithm.iteration;
import std.process : Config, environment, executeShell, execute, spawnShell, spawnProcess, wait;
import std.string : removechars;

// Class std.process.environment
// Manipulates environment variables using an associative-array-like interface.
// This class contains only static methods, and cannot be instantiated.

auto findExecutable(string exec)
{
    version(linux)
        string command = "whereis ";  // Linux uses whereis
    else version(Windows)
        string command = "where ";    // Windows uses where;
    else version(OSX)
        string command = "which ";    // Mac uses which

    auto at = executeShell(command ~ exec);
	if (at.status != 0)
	    writeln("Handle Error here");
    return at;
}


auto splitUpPaths(string envPath)
{
    version(linux)
        auto paths = std.algorithm.iteration.splitter(envPath, ':');  // Linux uses colon
    else version(Win64)
        auto paths = std.algorithm.iteration.splitter(envPath, ';');  // Windows uses semi-colons;
    else version(OSX)
        auto paths = std.algorithm.iteration.splitter(envPath, ':');  // MacOS uses colon
    return paths;
}

void main(char[][] args)
{
    // here we use the system provided enum and the variable os defined as
    // immutable OS os;  // The OS that the program was compiled for.

    writeln("This program was compiled for a ", os, " system.");
    writeln("And called with the following arguments");
    foreach (arg; args)
    {
        writeln(arg);
    }

    string progName = args[0].idup;  // get the command that called this program
	                                 // (should be dublin, dubwin, or dubmac)
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

    /+ Assumptions:
	    the duball (dublin, dubwin, dubmac) are located at and executed at the pre-defined
		projects folder which will hold individual projects
		<root>/projects   (where root is the root of the flash drive assigned by Linux or OSX)
		or
		X:\projects       (where X is the letter assigned by Windows to the flash drive)

		Windows Example:

		    after inserting a flash drive in windows, assume the flash drive is assigned letter E: (C: and D: were already taken by permanent drives of the system)
		    open a command window
		    cd to e:\projects
	        dubwin init myfirstproj

		    to build, link, run,
            cd myfirstproj
            ..\dubwin.exe run

		Linux Example:

		    after inserting a flash drive in linux, the flash drive is a path
		    open a terminal window
		    cd to <path>\projects
	        dublin init mysecondproj

		    to build, link, run,
            cd mysecondproj
            .\..\dublin run


			Windows then searches for the DLLs in the following sequence:
                o The directory where the executable module for the current process is located.
                o The current directory.
                o The Windows system directory. The GetSystemDirectory function retrieves the path of this directory.
                o The Windows directory. The GetWindowsDirectory function retrieves the path of this directory.
                o The directories listed in the PATH environment variable.

	+/

    string envPath = environment["PATH"];  // get the environment variable PATH.

    //writeln(" The environment variable $PATH on this machine is: ", envPath);

    auto paths = splitUpPaths(envPath);

    version(linux)
    {
	    string relDmdPath = r"./../Linux/dmd-2.071.0/linux/bin64:./../../Linux/dmd-2.071.0/linux/bin64:";
	    string relDubPath = r"./../Windows/dub:./../../Windows/dub:";
        string    dllPath = r"./../../linux/dynamiclibraries:";

      //LD_LIBRARY_PATH=/usr/local/lib
      //export LD_LIBRARY_PATH
      environment["LD_LIBRARY_PATH"] = r"./../../linux/dynamiclibraries:";
    } else version(Win64)
    {
	    //pragma(lib, r".\..\Windows\Windows Kits\10\Lib\10.0.10150.0\ucrt\x64");  // not allowed as statement
	    string relDmdPath = r".\..\Windows\D\dmd2\windows\bin;.\..\..\Windows\D\dmd2\windows\bin;";
	    string relDubPath = r".\..\Windows\dub;.\..\..\Windows\dub;";
        string   dllPath  = r".\..\..\windows\dynamiclibraries;";    // needed for glfw3.dll
        dllPath = r".\..\..\Windows\VisualStudio\VC\redist\x64\Microsoft.VC140.CRT;" ~ dllPath;

		/+ Microsoft quote "LIB, if defined. The LINK tools uses the LIB path when
		   searching for an object or library (example, libucrt.lib) +/

	    environment["LIB"] = r".\..\..\Windows\Windows Kits\10\Lib\10.0.14393.0\ucrt\x64";

		// The value of DFLAGS environment variable  is treated as if it were
		// appended to the command line to dmd.exe.

		environment["DFLAGS"] = `-I..\`;

		// set LINKCMD64=C:\Program Files (x86)\Microsoft Visual Studio 10.0\VC\bin\amd64\link.ex
	} else version(OSX)
    {
		string relDmdPath = r"./../MacOS/D/osx/bin:./../../MacOS/D/osx/bin:";
        string relDubPath = r"./../MacOS/dub:./../../MacOS/dub:" ~ r"./../../MacOS/dynamiclibraries:";
        // Dynamic (.dylib) libs can be placed at a nonstandard location in your file system, but only in
        // one of these environment variables: LD_LIBRARY_PATH, DYLD_FALLBACK_LIBRARY_PATH, or LD_LIBRARY_PATH
        string  dllPath  = r"./../../macos/dynamiclibraries:"; 

         environment["LD_LIBRARY_PATH"] = r"./../../macos/dynamiclibraries:";       
    }


	if ((!canFind(envPath, relDmdPath)) | (!canFind(envPath, relDubPath)) | (!canFind(envPath, dllPath)))
	{
	    //writeln("CANT FIND PATHS ===========================");
        version(Windows)
            envPath = relDmdPath ~ relDubPath ~ dllPath ~ envPath;
        else
            envPath = relDmdPath ~ relDubPath ~ dllPath ~ envPath;  // maybe call these soPath

		//writeln("new path = ", envPath);

	    environment["PATH"] = envPath;  // Update with new DMD and DUB paths

		envPath = environment["PATH"];    // get the environment variable PATH.
		//writeln("added new paths = ", envPath);
    }



    //string newPathVar = relDmdPath ~ relDubPath ~ envPath;

    //environment["PATH"] = newPathVar;  // Update the PATH environment


    paths = splitUpPaths(envPath);

	//writeln("\n","The PATH env variable now has paths:");
    foreach(path; paths)
    {
        //writeln("   ",path);
    }
     

    // auto res = execute(["dub", "help"]);
    // writeln("after dub", res.output);

    auto found = findExecutable("dmd");
    writeln("\n", "dmd", " was found at: ", found.output);

    found = findExecutable("dub");
    writeln("\n", "dub", " was found at: ", found.output);

    args[0] = "dub".dup;  // overwrite dubwin, dubmac, or dublin with the generic dup command

	writeln("calling spawnProcess with args = ", args);

	/+
    wait(spawnProcess("myapp", ["foo" : "bar"], Config.newEnv));

	auto pid = spawnProcess("myapp", stdin, stdout, logFile,
                             Config.retainStderr | Config.suppressConsole);

    @trusted Pid spawnProcess(in char[] program,
	                          File stdin = std.stdio.stdin,
							  File stdout = std.stdio.stdout,
							  File stderr = std.stdio.stderr,
							  const string[string] env = null,
							  Config config = Config.none,
							  in char[] workDir = null);
	+/


    /+
    By default, the child process inherits the environment of the parent process, along
	with any additional variables specified in the env parameter. If the same variable
	exists in both the parent's environment and in env, the latter takes precedence.
	+/

    auto pid = spawnProcess(args,
                            std.stdio.stdin,
                            std.stdio.stdout,
							std.stdio.stderr,
							null,
							Config.none,  /+ Config.none +/
							null
                            );
    scope(exit)
    {
        auto exitCode = wait(pid);
        writeln("myapp exited with code ", exitCode);
    }
    //    if (wait(pid) != 0)
    //	      writeln("spawnProcess failed.");

	/+
    else version(OSX)
    {
        auto paths = std.algorithm.iteration.splitter(envPath, ':');  // colon is path separator in Linux
        foreach(path; paths)
            writeln("   ",path);
        auto p = executeShell("pwd");  // Windows uses where; Linux uses whereis
        // p.output string has a "return" character at the end. How to get rid of it?
        string presentWorkingDirectory = removechars(p.output, "\n");
        writeln("presentWorkingDirectory =", presentWorkingDirectory, "nospace");
        writeln(" The newPathVar is: ", newPathVar);
        environment["PATH"] = newPathVar;  // UPDATE THE PATH VARIABLE
        envPath = environment["PATH"];  // get the just altered environment variable PATH.
        writeln("The altered environment PATH variable on this Linux machine: ", envPath);

        auto res = execute(["dub", "list"]);
        writeln("after dub", res.output);

        auto b = executeShell("echo $PATH");
        writeln("from ECHO result ", b.output);

        auto c = executeShell("which dmd");  // Windows uses where; Linux uses whereis
        writeln("which dmd ", c.output);
    }
    +/


 /+
    defined in std.system
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
    Version Identifier	Description
    Windows	            Microsoft Windows systems
    Win32	            Microsoft 32-bit Windows systems
    Win64	            Microsoft 64-bit Windows systems
    linux	            All Linux systems
    OSX	                Mac OS X
  +/

}
