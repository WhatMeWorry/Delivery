
This document explains how, when and where all the shared objects (dynamic) Linux libraries are
used with the Delivery repository










    - OpenGL3.0+
    - GLFW3
    - FreeImage
        http://freeimage.sourceforge.net
 
        Created in /usr/local/lib and moved to folder below this document.
            libfreeimage.3.17.0.dylib  libfreeimage.3.dylib  libfreeimage.dylib
        
    - FreeType
        https://www.freetype.org
 
        Created in /usr/local/lib and moved to folder below this document.
            libfreetype.6.dylib  libfreetype.dylib

    - fmod
        http://www.fmod.com
        download FMOD Studio Programmer’s API and Low Level Programmer API  Version 1.09.05
        In new folder, navigate down to FMOD Programmers API > api > lowlevel > lib
        and move the following dynamic libraries to the folder below this document.
            lbfmod.dylib  libfmodL.dylib 

    - Assimp

        brew install assimp
            ==> Pouring assimp-3.3.1.sierra.bottle.tar.gz
            ==> Using the sandbox
            /usr/local/Cellar/assimp/3.3.1: 55 files, 7.9MB        
            and move the following dynamic libraries to the folder below this document.
            libassimp.3.dylib  libassimp.dylib