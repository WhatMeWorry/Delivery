

The D Language, like other languages, has its own runtime library called [Phobos](https://dlang.org/phobos/index.html)

But there exists even more functionality in 3rd party libraries or **packages** as Dub calls them. Unlike Phobos, packages reside outside of the D Language and so must be explicitly connected with a D program. Will see how this is done shortly.

In short, DUB is the D package registry. It is also a command utility which allows D programs to easily incorporate DUB packages. 

The list of [Dub packages](https://code.dlang.org/) is extensive and always growing. Packages specilize in areas as diverse as File Systems, Graphical User Interfaces, Video, and Networking.

The are two main kinds of D pacakges: stand-alone applications or developmental libraries. Since Delivery itself consists of a collection of instructional programs, we will only be interested in the development libraries. There is even group of packages grouped as Candidates for inclusion in the D Standard Library; these are packages that, if eventually considered so useful and prevalent by the D community, will be rolled into Phobos officially. 

Since Delivery is primarily a tutorial about openGL3, we will need the [derelict-gl3](https://code.dlang.org/packages/derelict-gl3) package. Additionally, we will create a tutorial game where we will introduce images, sound, and text; This functionality, we can get through [derelict-sdl2](https://code.dlang.org/packages/derelict-sdl2)

How do we actually go about this?

I'm going to write a trivial, yet traditional, Hello World program.  I'll use dub to get us started.

```Batchfile
C:\>mkdir myprojects

C:\>cd myprojects

C:\myprojects>dub init HelloThenSound
Package recipe format (sdl/json) [json]: sdl
Name [hellothensound]:
Description [A minimal D application.]:
Author name [kheaser]:
License [proprietary]:
Copyright string [Copyright ┬⌐ 2018, kheaser]:
Add dependency (leave empty to skip) []:
Successfully created an empty project in 'C:\myprojects\HelloThenSound'.
Package successfully created in HelloThenSound
```
A new directory called HelloThenSound has been created.

```
C:\myprojects>dir

 Directory of C:\myprojects
01/04/2018  11:09 AM    <DIR>          HelloThenSound
```

A file called dub.sdl (or dub.json if you defaulted the above prompt: **Package recipe format (sdl/json) [json]:** has will be created with build information.  The .gitignore is a Github file which we can ignore for now.  And a new directory **source** has been created.

```
C:\myprojects>dir HelloThenSound

 Directory of C:\myprojects\HelloThenSound

01/04/2018  11:09 AM               172 .gitignore
01/04/2018  11:09 AM               140 dub.sdl
01/04/2018  11:09 AM    <DIR>          source
```

Let's look at what is in the source directory. It is called __source__ because here we will keep our source code.
 
``` 
C:\myprojects>dir HelloThenSound\source

 Directory of C:\myprojects\HelloThenSound\source

01/04/2018  11:09 AM                95 app.d
```

app.d is an D file consisting of D Language code. It is incredible trivial. But as every thousand mile journey begins with one step, app.d is our first step.  Open it up with your favorite editor and you should see:

```D
import std.stdio;

void main()
{
    writeln("Edit source/app.d to start your project.");
}
```

Using your text editor, change the output to 
```D
import std.stdio;

void main()
{
    writeln("Here we go", "\n");  // new line after Here we go  
    writeln("Hellow World - But where's the Sound?");
}
```

After saving off your changes, we will now use `dub run` command to compile, link, and run the program
```
C:\myprojects\HelloThenSound>dub run
Performing "debug" build using ldc2 for x86_64.
hellothensound ~master: building configuration "application"...
Running .\hellothensound.exe
Here we go

Hellow World - But where's the Sound?
```

You've now ran you first D program. But where is the sound.  Well, we didn't put any D code to make audio. And even if you looked through the entire D language or Phobos library, you would not find anything.  D, like COBOL, Fortran, C, C++, Java, Go, Rust, etc. doesn't have built-in support for sound.  Here is were 3rd party libraries come to the rescue, or in our case DUB packages.

You can go to [DUB](https://code.dlang.org/) website, and choose Select Category `Development Library` and `Audio Libraries` to show all the audio relevant packages. But instead, we are going to use the audio portion of a popular game package called [SDL](https://www.libsdl.org/). However, the D specific DUB package is called [derelict-sdl2](https://code.dlang.org/packages/derelict-sdl2) which has a component to [SDL2_mixer](https://www.libsdl.org/projects/SDL_mixer/docs/index.html)

Let's begin.  To our app.d

```D
import std.stdio;
import derelict.sdl2.mixer;  // import audio functionality

void main()
{
    writeln("Here we go", "\n");  //  new line after Here we go    
    writeln("Hellow World - But where's the Sound?");
		                         
    DerelictSDL2.load();         // Load the SDL 2 library.

    DerelictSDL2Mixer.load();   // Load the SDL2_mixer library.	
}
```
And re-run our program.
```
C:\myprojects\HelloThenSound>dub run
Performing "debug" build using ldc2 for x86_64.
hellothensound ~master: building configuration "application"...
source\app.d(2,8): Error: module mixer is in file 'derelict\sdl2\mixer.d' which cannot be read
ldc2 failed with exit code 1.
```

The error is because the program cannot fine the D code (which interfaces with the C code SDL2_mixer)
Easy fix. We can add a dependency to our dub.sdl file.  Open the dub.sdl file which is located in the folder above the source code and add the following line.

```
name "hellothensound"
description "A minimal D application."
authors "kheaser"
copyright "Copyright © 2018, kheaser"
license "proprietary"

dependency "derelict-sdl2" version="~>3.1.0-alpha.3"
```

Now try and run again.

```Batchfile
C:\myprojects\HelloThenSound>dub run
Performing "debug" build using ldc2 for x86_64.
derelict-util 3.0.0-beta.2: target for configuration "library" is up to date.
derelict-sdl2 3.1.0-alpha.3: target for configuration "derelict-sdl2-dynamic" is up to date.
hellothensound ~master: building configuration "application"...
source\app.d(9,5): Error: undefined identifier DerelictSDL2
```
 We now have the source code in derelict\sdl2\mixer.d, but we have a new error with undefined identifier DerelictSDL2. Compile now works but we don't have the run-time execuatable. We are falling off the cliff.  Goto the [SDL downloads](https://www.libsdl.org/download-2.0.php) and select on SDL2-2.0.7-win32-x64.zip or whatever is the current SDL2 release for 64 bits.
 
 ### Special Notes
 ***
 
After downloading the **Build Tools for Visual Studio 2017**  (Since we are using Visual Studio Code we don't need the full kitchen sink Visuald studio 2017).
 
We can  
 
 ```
 C:\Program Files (x86)\Microsoft Visual Studio\2017\BuildTools\Common7\Tools>vsdevcmd.bat
**********************************************************************
** Visual Studio 2017 Developer Command Prompt v15.0
** Copyright (c) 2017 Microsoft Corporation
**********************************************************************
 ```
 
I have an .H and a .LIB file of a library. I wrote a program and refrenced the LIB via the project properties. It compiles fine, but when it runs, it asks for the DLL to be installed. If the DLL is in the same dir as the EXE it works ... but, if I have the LIB, doesn't it already mean the functions are staticly linked to my program?


Not all `lib` files are static libraries. Some are import libraries, and chances are, that's what you linked with.

If your `lib` file is much smaller than its corresponding dll file, that's a sure sign that it's an import library.

	
You can also run dumpbin /exports on the .lib file and if you end up with a list of all the functions in the library, it's an import lib.

```
C:\myprojects\HelloThenSound>dumpbin /exports DerelictSDL2.lib >> file.txt
```

file.txt only showed the following

```
Microsoft (R) COFF/PE Dumper Version 14.12.25831.0
Copyright (C) Microsoft Corporation.  All rights reserved.

Dump of file DerelictSDL2.lib
File Type: LIBRARY
  Summary
        1C30 .bss
        3B88 .data
       157B0 .debug$S
            ...
          10 .tls$
         3F4 .xdata
```

lib /list is also useful. If you only see .obj references, then it is only static. If it only has .dll then it is an import only library. Note: that it is possible for a .lib file to be both.

```
C:\myprojects\HelloThenSound>lib /list DerelictSDL2.lib >> liblist.txt
```
liblist.txt shows

```
Microsoft (R) Library Manager Version 14.12.25831.0
Copyright (C) Microsoft Corporation.  All rights reserved.

.dub\obj\derelict.sdl2.ttf.obj
.dub\obj\derelict.sdl2.sdl.obj
.dub\obj\derelict.sdl2.net.obj
.dub\obj\derelict.sdl2.mixer.obj
.dub\obj\derelict.sdl2.internal.sdl_types.obj
.dub\obj\derelict.sdl2.internal.sdl_dynload.obj
.dub\obj\derelict.sdl2.internal.sdl_dynamic.obj
.dub\obj\derelict.sdl2.internal.gpu_types.obj
.dub\obj\derelict.sdl2.internal.gpu_dynload.obj
.dub\obj\derelict.sdl2.internal.gpu_dynamic.obj
.dub\obj\derelict.sdl2.image.obj
.dub\obj\derelict.sdl2.gpu.obj
.dub\obj\derelict.sdl2.config.obj
```

Letting your program use a DLL requires an import library. It is a file with the .lib extension, just like a static .lib. But it is very small, it only contains a list of the functions that are exported by the DLL. The linker needs this so it can embed the name of the DLL in the import table. You can see this for yourself by running Dumpbin.exe /imports on your .exe












### Random Error Note
***

Tried a subset of Visual Studio (not sure all the boxes I need to check)
```
hellothensound ~master: building configuration "application"...
LINK : fatal error LNK1181: cannot open input file 'kernel32.lib'
Error: C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.12.25827\bin\HostX64\x64\link.exe failed with status: 1181
ldc2 failed with exit code 1181.
```
I installed the you do not have any windows SDK installed

![Fig 1-0](https://user-images.githubusercontent.com/21070121/34625991-81511904-f220-11e7-8d21-193150088743.png)

Yay. it now works.
```
C:\myprojects\HelloThenSound>dub build
Performing "debug" build using ldc2 for x86_64.
derelict-util 3.0.0-beta.2: target for configuration "library" is up to date.
derelict-sdl2 3.1.0-alpha.3: target for configuration "derelict-sdl2-dynamic" is up to date.
hellothensound ~master: building configuration "application"...
To force a rebuild of up-to-date targets, run again with --force.
```

