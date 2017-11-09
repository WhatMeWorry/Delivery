

1)  New Windows 8.0 system.

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
            Build Tools for Visual Studio 2017   These Build Tools allow you to build native and manage
                                                 MSBuild-based applications without requiring the Visual Studio IDE	

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
	

	
	

		
		
		
		
		
		