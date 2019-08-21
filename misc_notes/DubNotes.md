
## Dub Notes


***

A brand new system with no dub packages
```
C:\>dub list
Packages present in the system and known to dub:
```

***

After deciding on the package you want, use the dub fetch command to download it.
the cache options may be either __system__, __user__ or __local__. If not specified, dub defaults to user.

* __system__ will download the package to C:\\ProgramData\\dub\\packages
* __user__ will download the package to either C:\\Users\\_username_\\AppData\\Local\\dub\\packages\\ or C:\\Users\\_username_\\AppData\\Roaming\\dub\\packages depending if the Windows computer is part of a domain or workgroup
* __local__ is used if you want to download the package to a user specified location. Specifying local will download the package to your current working directory. See below for more details.  


```
C:\>dub fetch derelict-sdl2 --cache=user
Fetching derelict-sdl2 2.1.4...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package 
to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.

C:\>dub list
Packages present in the system and known to dub:
  derelict-sdl2 2.1.4: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
```
The package has been downloded to the user directory **C:\\Users\\_user_\\AppData\\Roaming\\dub\\packages\\derelict-sdl2-2.1.4\\derelict-sdl2**

```
C:\>dub fetch derelict-sdl2 --cache=system
Fetching derelict-sdl2 2.1.4...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package 
to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.

C:\>dub list
Packages present in the system and known to dub:
  derelict-sdl2 2.1.4: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
  derelict-sdl2 2.1.4: C:\ProgramData\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
```

This system package has been downloded to the system directory **C:\\ProgramData\\dub\\packages\\derelict-sdl2-2.1.4\\derelict-sdl2**


It is a bit more invloved if want specify your own registry path, 
```
C:\>mkdir dublocal

C:\>cd dublocal

C:\dublocal>dub fetch derelict-sdl2 --cache=local
Fetching derelict-sdl2 2.1.4...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package 
to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.

```
The `dir` command will show that a derelict-sdl2 directory has been created.
But `dub list` won't show the new package, yet. Need to add it to the registry with:

```
C:\dublocal>dir

01/03/2018  01:00 PM    <DIR>          derelict-sdl2-2.1.4
01/03/2018  01:00 PM                 0 dub

C:\dublocal>dub list
Packages present in the system and known to dub:
  derelict-sdl2 2.1.4: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
  derelict-sdl2 2.1.4: C:\ProgramData\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
```

We need to explicitly add it to the registry with the `add-local` option

```
C:\dublocal>dub add-local .\derelict-sdl2-2.1.4\derelict-sdl2
Registered package: derelict-sdl2 (version: 2.1.4)
```
And now we can see local package too.
```
C:\dublocal>cd ..
C:\>dub list
Packages present in the system and known to dub:
  derelict-sdl2 2.1.4: C:\dublocal\derelict-sdl2-2.1.4\derelict-sdl2\
  derelict-sdl2 2.1.4: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
  derelict-sdl2 2.1.4: C:\ProgramData\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\  
```
The above package has been placed in all three directories for illustrative purposes. You normally would only have one repository downloaded because otherwise duplicate symbol names can arise.  For instance, a package called scone has been downloaded to both user and system. Trying to do a __dub build scone__ command results in duplicate names. Here the user package conflicts with the identical system package.

```
C:\ProgramData\dub\packages\scone-2.1.2\scone>dub build scone

C:\D\dmd2\windows\bin\..\..\src\druntime\import\core\stdc\stddef.d(15,1): Error: package name 'core' 
conflicts with usage as a module name in file 
C:\Users\kheaser\AppData\Local\dub\packages\scone-2.1.0\scone\source\scone\core.d

```
***

Once a package is downloaded, it needs to be built.  
C:\ProgramData\dub\packages\scone-2.1.2\scone

```
C:\Users\kheaser>dub build scone
Building package scone in C:\ProgramData\dub\packages\scone-2.1.2\scone\
Performing "debug" build using dmd for x86.
scone 2.1.2: building configuration "library"...
```
After the build command, a new directory called bin is created with the just created scone library: 
&nbsp;
C:\ProgramData\dub\packages\scone-2.1.2\scone\bin\scone.lib
This is specified by the dub.json file

"targetPath": "bin/",
"name": "scone"
"configurations": "targetType": "library"

***

By default, it looks like Dub on Windows trys to find packages locally at either of these two paths.

Looking for local package map at C:\ProgramData\dub\packages\local-packages.json



Looking for local package map at C:\Users\kheaser\AppData\Roaming\dub\packages\local-packages.json

```
C:\Users\kheaser\AppData\Roaming\dub\packages>dir /a

11/08/2017  01:00 PM               994 local-packages.json
```


***

To completely clean off Dub entirely, do the following on Windows:

```
cd C:\Users\_username_\AppData\Roaming
// or
cd C:\Users\<username>\AppData\Local
// or
cd C:\ProgramData\


rd /s /q dub

dub list
Packages present in the system and known to dub:

```

In Linux, to completely remove local Dub packages with the rm command:
-f = to ignore non-existent files, never prompt
-r = to remove directories and their contents recursively
-v = to explain what is being done

```
$ dub list
Packages present in the system and known to dub:
  bindbc-freeimage 0.1.1: /home/generic/.dub/packages/bindbc-freeimage-0.1.1/bindbc-freeimage/
  bindbc-glfw 0.4.0: /home/generic/.dub/packages/bindbc-glfw-0.4.0/bindbc-glfw/
     o   o   o
     
$ sudo rm -frv .dub
removed '.dub/packages/bindbc-freeimage-0.1.1/bindbc-freeimage/.dub/build/dynamic-debug-linux.posix-x86_64-ldc_2084-7AD98CBFBCB678B6EDD1C29FF9DD5AE2/libBindBC_FI.a'

dub list
Packages present in the system and known to dub:

```

***

#### How to delete Dub packages

```
C:\>dub list
Packages present in the system and known to dub:
  derelict-sdl2 2.1.4: C:\dublocal\derelict-sdl2-2.1.4\derelict-sdl2\
  derelict-sdl2 2.1.4: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
  
C:\>dub remove derelict-sdl2
Removing derelict-sdl2 in C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
Removed package: 'derelict-sdl2'
Removed derelict-sdl2, version 2.1.4.

C:\>dub list
Packages present in the system and known to dub:
  derelict-sdl2 2.1.4: C:\dublocal\derelict-sdl2-2.1.4\derelict-sdl2\
  
C:\Users\Kyle\AppData\Roaming\dub\packages>dub remove bindbc-sdl
Select version of 'bindbc-sdl' to remove from location 'user':
1) 0.1.0
2) 0.7.0
3) all versions
> 3
Removing bindbc-sdl in C:\Users\Kyle\AppData\Roaming\dub\packages\bindbc-sdl-0.1.0\bindbc-sdl\
Removed package: 'bindbc-sdl'
Removed bindbc-sdl, version 0.1.0.
Removing bindbc-sdl in C:\Users\Kyle\AppData\Roaming\dub\packages\bindbc-sdl-0.7.0\bindbc-sdl\
Removed package: 'bindbc-sdl'
Removed bindbc-sdl, version 0.7.0.

```
If not useing the default package location, you must specify the whole path 
```
C:\>dub remove-local C:\dublocal\derelict-sdl2-2.1.4\derelict-sdl2
Deregistered package: derelict-sdl2 (version: 2.1.4)

C:\>dub list
Packages present in the system and known to dub:
```
***




How to make a user created dub project use an existing dub package.
There are hundreds of packages of existing libraries in the DUB repository.  We are going to make a little custom application which will use the package scone. We'll call thus tutorial tiny.

```
C:\Users\kheaser\D_development>dub init tiny
Package recipe format (sdl/json) [json]: sdl
Name [tiny]:
Description [A minimal D application.]:
Author name [kheaser]:
License [proprietary]:
Copyright string [Copyright ┬⌐ 2019, kheaser]:
Add dependency (leave empty to skip) []: scone
Added dependency scone ~>2.1.2
Add dependency (leave empty to skip) []:
Successfully created an empty project in 'C:\Users\kheaser\D_development\tiny'.
Package successfully created in tiny
```
When running a dub project, need to be in the root of the project

```
C:\Users\kheaser\D_development>dub build tiny
Failed to find a package named 'tiny'.
```
Change to current working directory to the tiny project

```
C:\Users\kheaser\D_development>cd tiny
```
And try the build command again:

```
C:\Users\kheaser\D_development\tiny>dub build tiny
Building package tiny in C:\Users\kheaser\D_development\tiny\
Performing "debug" build using dmd for x86.
scone 2.1.2: building configuration "library"...
tiny ~master: building configuration "application"...
Linking...
```
The build will create a file __app.d__ in a new folder __source__

```
C:\Users\kheaser\D_development\tiny>dir source

08/20/2019  04:25 PM    <DIR>          .
08/20/2019  04:25 PM    <DIR>          ..
08/20/2019  04:25 PM                89 app.d
               1 File(s)             89 bytes
               2 Dir(s)  321,120,731,136 bytes free
```
The build command in dub only compiles. To execute your binary do: 
```
C:\Users\kheaser\D_development\tiny>dub run
Performing "debug" build using dmd for x86.
scone 2.1.2: target for configuration "library" is up to date.
tiny ~master: target for configuration "application" is up to date.
To force a rebuild of up-to-date targets, run again with --force.
Running .\tiny.exe
Edit source/app.d to start your project.
```
filler

```
C:\Users\kheaser\D_development\tiny>dub build --arch=x86_64 --compiler=ldc2 --build=release
Performing "release" build using ldc2 for x86_64.
scone 2.1.2: building configuration "library"...
C:\ProgramData\dub\packages\scone-2.1.2\scone\source\scone\window.d(211,13): Deprecation: foreach: loop index implicitly converted from size_t to uint
C:\ProgramData\dub\packages\scone-2.1.2\scone\source\scone\window.d(213,17): Deprecation: foreach: loop index implicitly converted from size_t to uint
tiny ~master: building configuration "application"...
```
All the code files in __source__ directory (just __app.d__ in our case) will be compiled and linked into the executable __tiny.exe__.

Notice that scone was also compiled because this is the package specified in the __dub.sdl__ file created in the previous __dub init__ command.

Now add __import scone;__ line so we can import all the symbols so we will be able to use all the functionality provied by the scone package.  Since the symbols are imported, we can use all the functional goodness that the scone package offers. 
```
import std.stdio;
import scone;

void main()
{   window.resize(80,24);
    window.title = "Tiny Example";
	window.print;
	foreach(n; 0..800000) { window.print; }
}
```

Now recompile and run this new code:

```
C:\Users\kheaser\D_development\tiny>dub build --arch=x86_64 --compiler=ldc2
Performing "debug" build using ldc2 for x86_64.
scone 2.1.2: target for configuration "library" is up to date.
tiny ~master: target for configuration "application" is up to date.
To force a rebuild of up-to-date targets, run again with --force.
```
Now run the new program with

```
C:\Users\kheaser\D_development\tiny>tiny.exe
```
and a small window should pop up named "Tiny Exampls"

***


have very simple dub.sdl with just:

dependency "derelict-util"  version="~>2.0.6"
dependency "derelict-glfw3" version="~>3.1.0"

Using dub registry url 'http://code.dlang.org/'
Refreshing local packages (refresh existing: true)...

Looking for local package map at C:\ProgramData\dub\packages\local-packages.json
Looking for local package map at C:\Users\kheaser\AppData\Roaming\dub\packages\local-packages.json





===============================================================================================


dub upgrade must be done in directory where a dub.sdl resides.  For Instance:
```
C:\Users\kheaser\Delivery\apps>dub upgrade bindbc-freeimage
There was no package description found for the application in 'C:\Users\kheaser\Delivery\apps'.
Upgrading project in C:\Users\kheaser\Delivery\apps
```
The above upgrade fails, but when you cd to a directory with a dub.sdl file it works.

```
C:\Users\kheaser\Delivery\apps>cd Kyle

C:\Users\kheaser\Delivery\apps\kyle>type dub.sdl
name "kyle"
description "test"
authors "kheaser"
copyright "Copyright ┬⌐ 2019, kheaser"
license "proprietary"

dependency "bindbc-freeimage" version="~>0.1.0"
subConfiguration "bindbc-freeimage" "static"
libs "freeimage"



C:\Users\kheaser\Delivery\apps\kyle>dub upgrade bindbc-freeimage
Upgrading project in C:\Users\kheaser\Delivery\apps\kyle
```

***

```
C:\ProgramData\dub\packages\scone-2.1.2\scone\examples>ldc2  -I=C:\ProgramData\dub\packages\scone-2.1.2\scone\source\ example_1.d
example_1.d(26): Error: function scone.color.foreground(Color color) is not callable using argument types (int)
example_1.d(26):        cannot pass argument uniform(0, 16) of type int to parameter Color color
example_1.d(27): Error: function scone.color.background(Color color) is not callable using argument types (int)
example_1.d(27):        cannot pass argument uniform(0, 16) of type int to parameter Color color
C:\ProgramData\dub\packages\scone-2.1.2\scone\source\scone\window.d(211): Deprecation: foreach: loop index implicitly converted from size_t to uint
C:\ProgramData\dub\packages\scone-2.1.2\scone\source\scone\window.d(213): Deprecation: foreach: loop index implicitly converted from size_t to uint
```

***

C:\ProgramData\dub\packages\scone-2.1.2\scone\examples>dmd -c  -I=C:\ProgramData\dub\packages\scone-2.1.2\scone\source\ example_2.d

C:\ProgramData\dub\packages\scone-2.1.2\scone\examples>link.exe
OPTLINK (R) for Win32  Release 8.00.17
Copyright (C) Digital Mars 1989-2013  All rights reserved.
http://www.digitalmars.com/ctg/optlink.html
OBJ Files: (.obj):example_2
Output File: (example_2.exe):
Map File: (.map):
Libraries and Paths: (.lib):scone.lib
Definition File: (.def):
Resource Files: (.res):

C:\ProgramData\dub\packages\scone-2.1.2\scone\examples>example_2.exe

object.Error@(0): Stack Overflow

C:\ProgramData\dub\packages\scone-2.1.2\scone\examples>example_2

object.Error@(0): Stack Overflow
