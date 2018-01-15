

```D
require 'redcarpet'
markdown = Redcarpet.new("Hello World!")
puts markdown.to_html
```

```Batchfile
cd \to\path
dir
```


- George Washington
- John Adams
- Thomas Jefferson


1)  New Windows 8.0 system.  Mac OS below:

2)  Install LLVM D Compiler (LDC)

    Goto https://github.com/ldc-developers/ldc/releases
        Download  ldc2-1.5.0-win64-msvc.zip
            extract .zip file to a new folder on c: drive.  It will automatically make a folder called \ldc2-1.5.0-win64-mscv
			rename the folder to just ldc2 (to simplify step 4)
			
	No installation is required. Simply use the executables in the bin subfolder.

    Must have Microsoft C++ 2015 or 2017 installation, either via Visual Studio
    or the standalone "Visual C++ Build Tools".	
 
    "The new Visual Studio Build Tools provides a lightweight option for installing the tools you need without requiring the Visual Studio IDE.  visit http://aka.ms/visualcpp"
 
    LDC relies on the MS linker and MSVCRT + WinSDK lib
			
3)  Goto https://www.visualstudio.com/downloads/?q=build+tool#build-tools-for-visual-studio-2017

    vs_buildtools_1599795229  (setup application)

    Under Other Tools and Frameworks
    Build Tools for Visual Studio 2017   These Build Tools allow you to
                                         build native and manage
                                         MSBuild-based applications without 
                                         requiring the Visual Studio IDE

    Left all the default selected options as is.    
	
4)  Will be using cmd.exe window.  Added path to PATH env variable of 

    Set modifies the current shell's (window) environment values, and the change is available immediately, but it is temporary. The change will not affect other shells that are running, and as soon as you close the shell, the new value is lost until such time as you run set again.

    setx modifies the value permenantly, which affects all future shells, but does not modify the environment of the shells already running. You have to exit the shell and reopen it before the change will be available, but the value will remain modified until you change it again.
	
    setx PATH %PATH%;c:\my-user-specifc-bin-path
    or
    setx PATH "%PATH%;C:\ldc2\bin"

5)  Note: DUB is present in the c:\ldc2\bin folder as a convenience!

6)  Create a minimal DUB D project

    dub init myproject

```Batchfile
    C:\>dub init myproject
    Package recipe format (sdl/json) [json]: sdl
    Name [myproject]:
    Description [A minimal D application.]:
    Author name [kheaser]:
    License [proprietary]:
    Copyright string [Copyright ┬⌐ 2017, kheaser]:
    Add dependency (leave empty to skip) []:
    Successfully created an empty project in 'C:\myproject'.
    Package successfully created in myproject

    C:\>cd myproject	

    C:\Users\Administrator\myproject>dub build
    Performing "debug" build using ldc2 for x86_64.
    myproject ~master: building configuration "application"...
```

    // And runs

    C:\Users\Administrator\myproject>dub run
    Performing "debug" build using ldc2 for x86_64.
    myproject ~master: target for configuration "application" is up to date.
    To force a rebuild of up-to-date targets, run again with --force.
    Running .\myproject.exe
    Edit source/app.d to start your project.
	
    edited the app.d source file to say "********** HELO WORLD **********"

    name "myproject"
    description "A minimal D application."
    authors "Administrator"
    copyright "Copyright © 2017, Administrator"
    license "proprietary"

    dependency "derelict-util"    version= "==2.1.0"
    dependency "derelict-glfw3"   version= "==3.1.3"
    dependency "derelict-gl3"     version= "==1.0.23"
    dependency "derelict-fi"      version= "==2.0.3"
    dependency "derelict-ft"      version= "==1.1.3"
    dependency "derelict-al"      version= "==1.0.3"
    dependency "derelict-fmod"    version= "==4.1.0"
    dependency "derelict-assimp3" version= "==1.3.0"

	
	// After several runs, all libraries are built

    C:\Users\Administrator\myproject>dub run
    Performing "debug" build using ldc2 for x86_64.
    derelict-util 2.1.0: target for configuration "library" is up to date.
    derelict-al 1.0.3: target for configuration "library" is up to date.
    derelict-assimp3 1.3.0: target for configuration "library" is up to date.
    derelict-fi 2.0.3: target for configuration "library" is up to date.
    derelict-fmod 4.1.0: target for configuration "library" is up to date.
    derelict-ft 1.1.3: target for configuration "library" is up to date.
    derelict-gl3 1.0.23: target for configuration "library" is up to date.
    derelict-glfw3 3.1.3: target for configuration "derelict-glfw3-dynamic" is up to date.
    myproject ~master: target for configuration "application" is up to date.
    To force a rebuild of up-to-date targets, run again with --force.
    Running .\myproject.exe
    ********** HELO WORLD **********
	
	
    When brought over to Windows 10 Surface Book (with DMD already installed) problems arose
	
In Powershell, ran

    **Powershell will inherit the environment of the process that launched it.
	    ECHO.%PATH:;= & ECHO.%
    will be identical to
        $env:path.split(";")
    if powershell is started from the cmd.exe window.  Simply open a cmd windows and type powershell.
        P:\>powershell
        Windows PowerShell
        Copyright (C) 2016 Microsoft Corporation. All rights reserved.

    The reverse is also true!		
		
Microsoft Windows [Version 10.0.15063]
(c) 2017 Microsoft Corporation. All rights reserved.

P:\>ECHO.%PATH:;= & ECHO.%
C:\WINDOWS\system32
C:\WINDOWS
C:\WINDOWS\System32\Wbem
C:\WINDOWS\System32\WindowsPowerShell\v1.0\
C:\Program Files\Microsoft SQL Server\120\Tools\Binn\
C:\Program Files\Microsoft SQL Server\130\Tools\Binn\
C:\Users\Administrator\Desktop\VisualStudio\VC\bin\
C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\
C:\Program Files\Microsoft SQL Server\110\Tools\Binn\
C:\Program Files (x86)\Microsoft SDKs\TypeScript\1.0\
C:\Program Files (x86)\Skype\Phone\
C:\WINDOWS\system32
C:\WINDOWS
C:\WINDOWS\System32\Wbem
C:\WINDOWS\System32\WindowsPowerShell\v1.0\
C:\Program Files\Microsoft SQL Server\120\Tools\Binn\
C:\Program Files\Microsoft SQL Server\130\Tools\Binn\
C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\
C:\Program Files\Microsoft SQL Server\110\Tools\Binn\
C:\Program Files (x86)\Microsoft SDKs\TypeScript\1.0\
C:\Program Files (x86)\Skype\Phone\
C:\Program Files (x86)\dub
C:\Users\kheaser\AppData\Local\Microsoft\WindowsApps
C:\Program Files\CMake\bin
C:\ldc2\bin

P:\>powershell
Windows PowerShell
Copyright (C) 2016 Microsoft Corporation. All rights reserved.

PS P:\> $env:path.split(";")
C:\WINDOWS\system32
C:\WINDOWS
C:\WINDOWS\System32\Wbem
C:\WINDOWS\System32\WindowsPowerShell\v1.0\
C:\Program Files\Microsoft SQL Server\120\Tools\Binn\
C:\Program Files\Microsoft SQL Server\130\Tools\Binn\
C:\Users\Administrator\Desktop\VisualStudio\VC\bin\
C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\
C:\Program Files\Microsoft SQL Server\110\Tools\Binn\
C:\Program Files (x86)\Microsoft SDKs\TypeScript\1.0\
C:\Program Files (x86)\Skype\Phone\
C:\WINDOWS\system32
C:\WINDOWS
C:\WINDOWS\System32\Wbem
C:\WINDOWS\System32\WindowsPowerShell\v1.0\
C:\Program Files\Microsoft SQL Server\120\Tools\Binn\
C:\Program Files\Microsoft SQL Server\130\Tools\Binn\
C:\Program Files (x86)\Windows Kits\10\Windows Performance Toolkit\
C:\Program Files\Microsoft SQL Server\110\Tools\Binn\
C:\Program Files (x86)\Microsoft SDKs\TypeScript\1.0\
C:\Program Files (x86)\Skype\Phone\
C:\Program Files (x86)\dub
C:\Users\kheaser\AppData\Local\Microsoft\WindowsApps
C:\Program Files\CMake\bin
C:\ldc2\bin
PS P:\>
		
		
7)  TL;DR  Make sure you have c:\ldc2\bin in either you path for powershell if your 
    working in powershell, or path in command line if your working in cmd.exe
	Just type in ldc2 and dub an make sure both are found.
	

	

1) Install on Mac OS 10.7 or newer
$brew install ldc
Updating Homebrew...
==> Downloading https://homebrew.bintray.com/bottles-portable/portable-ruby-2.3.3.leopard_64.bottle.1.tar.gz
######################################################################## 100.0%
==> Pouring portable-ruby-2.3.3.leopard_64.bottle.1.tar.gz
==> Auto-updated Homebrew!
Updated 1 tap (homebrew/core).
Clems-iMac:~ clemfandango$ brew install ldc
Error: ldc 1.2.0 is already installed
To upgrade to 1.5.0, run `brew upgrade ldc`
Clems-iMac:~ clemfandango$ brew upgrade ldc
==> Upgrading 1 outdated package, with result:
ldc 1.5.0
==> Upgrading ldc 
==> Installing dependencies for ldc: llvm
==> Installing ldc dependency: llvm
==> Downloading https://homebrew.bintray.com/bottles/llvm-5.0.0.sierra.bottle.tar.gz

2) Verify that D compiler LLVM was installed by:

$ which ldc2
/usr/local/bin/ldc2
Clems-iMac:bin clemfandango$ ls -al  /usr/local/bin | grep Nov
drwxrwxr-x  37 clemfandango  admin  1258 Nov 14 11:07 .
drwxr-xr-x  14 root          wheel   476 Nov 13 17:32 ..
lrwxr-xr-x   1 clemfandango  admin    33 Nov 14 11:07 assimp -> ../Cellar/assimp/4.0.1/bin/assimp
lrwxr-xr-x   1 clemfandango  admin    32 Nov 14 11:07 ccmake -> ../Cellar/cmake/3.9.6/bin/ccmake
lrwxr-xr-x   1 clemfandango  admin    31 Nov 14 11:07 cmake -> ../Cellar/cmake/3.9.6/bin/cmake
lrwxr-xr-x   1 clemfandango  admin    37 Nov 14 11:07 cmakexbuild -> ../Cellar/cmake/3.9.6/bin/cmakexbuild
lrwxr-xr-x   1 clemfandango  admin    31 Nov 14 11:07 cpack -> ../Cellar/cmake/3.9.6/bin/cpack
lrwxr-xr-x   1 clemfandango  admin    31 Nov 14 11:07 ctest -> ../Cellar/cmake/3.9.6/bin/ctest
lrwxr-xr-x   1 clemfandango  admin    44 Nov 14 11:07 freetype-config -> ../Cellar/freetype/2.8.1/bin/freetype-config
lrwxr-xr-x   1 clemfandango  admin    33 Nov 14 11:07 glewinfo -> ../Cellar/glew/2.1.0/bin/glewinfo
lrwxr-xr-x   1 clemfandango  admin    41 Nov 13 14:16 ldc-build-runtime -> ../Cellar/ldc/1.5.0/bin/ldc-build-runtime
lrwxr-xr-x   1 clemfandango  admin    36 Nov 13 14:16 ldc-profdata -> ../Cellar/ldc/1.5.0/bin/ldc-profdata
lrwxr-xr-x   1 clemfandango  admin    39 Nov 13 14:16 ldc-prune-cache -> ../Cellar/ldc/1.5.0/bin/ldc-prune-cache
lrwxr-xr-x   1 clemfandango  admin    28 Nov 13 14:16 ldc2 -> ../Cellar/ldc/1.5.0/bin/ldc2
lrwxr-xr-x   1 clemfandango  admin    29 Nov 13 14:16 ldmd2 -> ../Cellar/ldc/1.5.0/bin/ldmd2
lrwxr-xr-x   1 clemfandango  admin    41 Nov 14 11:07 libpng-config -> ../Cellar/libpng/1.6.34/bin/libpng-config
lrwxr-xr-x   1 clemfandango  admin    43 Nov 14 11:07 libpng16-config -> ../Cellar/libpng/1.6.34/bin/libpng16-config
lrwxr-xr-x   1 clemfandango  admin    40 Nov 14 11:07 png-fix-itxt -> ../Cellar/libpng/1.6.34/bin/png-fix-itxt
lrwxr-xr-x   1 clemfandango  admin    34 Nov 14 11:07 pngfix -> ../Cellar/libpng/1.6.34/bin/pngfix
lrwxr-xr-x   1 clemfandango  admin    35 Nov 14 11:07 visualinfo -> ../Cellar/glew/2.1.0/bin/visualinfo


LD_LIBRARY_PATH is used by your program to search directories containing shared libraries after it has been successfully compiled and linked.

LD_LIBRARY_PATH is searched when the program starts, LIBRARY_PATH is searched at link time.







```
Bell Labs 
Unix ---+---- BSD Family --+---- OpenBSD
                           +---- FreeBSD
                           +---- NetBSD
                           +---- SUN OS (Stanford Uni Network)       
                           +---- Next Step ------ Mac OS X  
        +---- SRV 5 -------+---- IRIX (SGI)
                           +---- AIX (IBM)
                           +---- Sun Solaris
                           +---- HP/UX

              GNU ----- Linux --+---- Slackware ---+---- SUSE ---- Open Suse
                                                   +---- Mini Slack ---- Zenwalk
                                                   +---- Frugalware
                                +---- Debian (.deb packages) ---- Ubuntu ----+---- Linux Mint
                                                                             +---- Xubuntu
                                                                             +---- Kubuntu
                                +---- Red Hat (.rpm packages) ------+----- CentOS
                                                                    +----- Mandrake
                                                                    +----- Fedora

                                Ubuntu LTS ---- Arch (pacman) ---Antergos (Arch with installer)

```

	

1) Install on Linux  (Antergos - Arch with an easy to use installer)

On terminal   (will be using yaourt: a pacman frontend)
yaourt -Syu --aur should show you upgradable aur packages.

$ sudo yaourt -Syyu
follow all the prompts to update everything.  (Visual Studio Code)




There are two Linux C/C++ library types which can be created:

Static libraries (.a): Library of object code which is linked with, and becomes part of the application.
Dynamically linked shared object libraries (.so): There is only one form of this library but it can be used in two ways.
Dynamically linked at run time. The libraries must be available during compile/link phase. The shared objects are not included into the executable component but are tied to the execution.
Dynamically loaded/unloaded and linked during execution (i.e. browser plug-in) using the dynamic linking loader system functions.
Library naming conventions:

Libraries are typically named with the prefix "lib". This is true for all the C standard libraries. When linking, the command line reference to the library will not contain the library prefix or suffix.



		
		
		
		
		
