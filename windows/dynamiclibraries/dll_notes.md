

## This document describes the DLL (Dynamic Link Libraries) used by Windows. It summarizes which
dynamic libraries are used and when and where they were originally downloaded from. Some DLLs may
already exist on a system, but these DLLS are placed here for version consistency and convenience.  

### Overview
This is an introduction to Git version control system. It teachs by doing: a step by step walkthru of all the commands listed in the required order. It is believed that theory is better understood after the user first knows the lay of the land. For Git to become really powerful/useful, it needs to paired with a remote repository.  


### Dynamic Libraries
    - Assimp (Assest )
        Downloaded from fmod web site: http://assimp.sourceforge.net/ assimp 3.1.1: released June 2014

        Then unzipped to create Users\user\Downloads\assimp-3.1.1-win-binaries\bin64\assimp.dll (3,716 KB)
        and moved assimp.dll to this folder.


    - fmod
        Needed to create an account.  Then Downloaded from fmod web site and created: C:\Program Files (x86)\FMOD SoundSystem\FMOD Studio API Windows\api\lowlevel\lib

        Renamed fmod64.dll and fmodL64.dll to fmod.dll and fmodL.dll respectively.

        Then moved fmod.dll and fmodL.dll to this folder.

    - FreeImage
        Went to the official FreeImage website: http://freeimage.sourceforge.net and

        downloaded FreeImage 3.17.0 [WIN32/WIN64]

        Got the FreeImage.dll (6,253 KB) from C:\Users\user\Downloads\FreeImage3170Win32Win64\FreeImage\Dist\x64
        and moved it to this folder.

    - GLFW3
        At the official  http://www.glfw.org/  There is a pre-built Windows pre-compiled binary for 64-bits. Then 
        downloaded glfw-3.2.1.bin.WIN64
        
        Got the most current lib-vc2015 glfw3.dll (82 KB) and copied it to this folder. Note: ignored lib-vc2012 and lib-vc2013.
    
    - FreeType
        
        The libfreetype-6.dll (1,187 KB) in this folder was obtained from:
        C:\Users\user\AppData\Roaming\dub\packages\dlangui-0.9.8\dlangui\libs\windows\x86_64  ????

    - OpenAL
        Went to the official openal website: https://www.openal.org/downloads/ and downloaded their openAL 1.1 windows 
        installer which placed a 
        64 bit openAL32.dll in C:\Windows\System32 and a 
        32 bit openAL32.dll in C:\Windows\SysWOW64 

        It is counterintuitive but System32 holds the 64 bit DLLs.
    
    - OpenGL
        opengl32.dll seems to be installed by default in C:\Windows\System32  
        (System32 = 64 bits; SystemWoW64 = 32 bits)

        Since opengl32.dll is a already a part of Windows, it will not be present in this folder. 
        
        