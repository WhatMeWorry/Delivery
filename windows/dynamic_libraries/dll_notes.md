

## This document describes the DLL (Dynamic Link Libraries) used by Windows. It summarizes which
dynamic libraries are used and when and where they were originally downloaded from. Some DLLs may
already exist on a system, but these DLLS are placed here for version consistency and convenience.  

### Overview
This is an introduction to Git version control system. It teachs by doing: a step by step walkthru of all the commands listed in the required order. It is believed that theory is better understood after the user first knows the lay of the land. For Git to become really powerful/useful, it needs to paired with a remote repository.  

| Important: Visual Studio Code / Git / Github was not able to <br> differentiate between different versions of .dll files. Push did <br> not work. Had to manually upload the .dll files from Github.
| :-------------------------------------------------------                                         |

### Dynamic Libraries
    - Assimp (Assest )
        Downloaded from web site: http://assimp.sourceforge.net/ assimp 3.1.1: released June 2014

        Then unzipped to create Users\user\Downloads\assimp-3.1.1-win-binaries\bin64\assimp.dll (3,716 KB)
        and moved assimp.dll to this folder.

    - sdl2  sdl2_mixer

    - FreeImage
        Went to the official FreeImage website: http://freeimage.sourceforge.net and

        downloaded FreeImage 3.17.0 [WIN32/WIN64]

        Got the FreeImage.dll (6,780 KB) from C:\Users\user\Downloads\FreeImage3100Win32Win64\FreeImage\Dist\x64
        and moved it to this folder.

    - GLFW3
        At the official  http://www.glfw.org/  Selected GLFW 3.3.8. Then selected "Windows pre-compiled binaries". Then selected 64-bit Windows binaries. Then 
        downloaded glfw-3.3.8.bin.WIN64.
		
        Copied the most current lib-vc2022 glfw3.dll (212 KB) into this folder.
    
    - FreeType
        The freetype.dll here in this directory was built by me using Visual Studio 2019 Community. The source
        was downloaded on April 2019.  This is version 2.10.0 and is of course a Windows .dll and build with "release" and "64 bit"
    
    - OpenGL
        opengl32.dll seems to be installed by default in C:\Windows\System32  
        (System32 = 64 bits; SystemWoW64 = 32 bits)

        Since opengl32.dll is a already a part of Windows, it will not be present in this folder. 
        
        
