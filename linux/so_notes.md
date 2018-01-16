
This document explains how, when and where all the shared objects (dynamic) Linux libraries are
used with the Delivery repository.  Specifically, we will assume Ubuntu 17.10, one of the most popular
Linux distributions.


    - OpenGL3.0+
    - GLFW3
    - SDL2_mixer


```
$ lsb_release -a
No LSB modules are available.
Distributor ID:	Ubuntu
Description:	Ubuntu 17.10
Release:	17.10
Codename:	artful 
```   

========================== GLFW ============================


Went to Github, and found the GLFW project. Clicked on the green button that copies the
path to here.

back on a terminal

git clone https://github.com/glfw/glfw.git

cd glfw

sudo make

sudo make install

Install the project...
-- Install configuration: ""
-- Up-to-date: /usr/local/include/GLFW
-- Up-to-date: /usr/local/include/Ubuntu 17.10GLFW/glfw3.h
-- Up-to-date: /usr/local/include/GLFW/glfw3native.h
-- Up-to-date: /usr/local/lib/cmake/glfw3/glfw3Config.cmake
-- Up-to-date: /usr/local/lib/cmake/glfw3/glfw3ConfigVersion.cmake
-- Up-to-date: /usr/local/lib/cmake/glfw3/glfw3Targets.cmake
-- Up-to-date: /usr/local/lib/cmake/glfw3/glfw3Targets-noconfig.cmake
-- Up-to-date: /usr/local/lib/pkgconfig/glfw3.pc
-- Up-to-date: /usr/local/lib/libglfw.so.3.3
-- Up-to-date: /usr/local/lib/libglfw.so.3
-- Up-to-date: /usr/local/lib/libglfw.so


===================== FREEIMAGE =============================

    - FreeImage
        http://freeimage.sourceforge.net
 

generic@generic ~]$ sudo pacman -S freeimage
resolving dependencies...
looking for conflicting packages...

Packages (1) freeimage-3.17.0-2

Total Installed Size:  13.39 MiB

:: Proceed with installation? [Y/n] Y
(1/1) checking keys in keyring                                           [########################################] 100%
(1/1) checking package integrity                                         [########################################] 100%
(1/1) loading package files                                              [ced in default user binary directories at install time
 // so paths don't need to be modified to run these two

 // This error appeared on Antergos Linux
 // object.Exception@std/process.d(3171): Environment variable not found: LD_LIBRARY_PATH
 // when commented out the following line:
 environment["LD_LIBRARY_PATH"] = `./../../linux/dynamiclibraries:/ignore/thi########################################] 100%
(1/1) checking for file conflicts                                        [########################################] 100%
(1/1) checking available disk space                                      [########################################] 100%
:: Processing package changes...
(1/1) installing freeimage                                               [########################################] 100%
:: Running post-transaction hooks...
(1/1) Arming ConditionNeedsUpdate...

        
    - FreeType
        https://www.freetype.org
 


======================= SDL2 and SDL2_mixer ==================================

```
$ sudo apt-get install libsdl2-dev
Reading package lists...

sudo apt-get install libsdl2-mixer-dev
Reading package lists... Done
```

Ubuntu installed SDL2 and extension to 
/usr/lib/x86_64-linux-gnu/  

Moved all the libSDL2_mixer-2.0.so.0 and libSDL2.so to Delivery/linux/dynamiclibraries






    - Assimp

        brew install assimp
            ==> Pouring assimp-3.3.1.sierra.bottle.tar.gz
            ==> Using the sandbox
            /usr/local/Cellar/assimp/3.3.1: 55 files, 7.9MB        
            and move the following dynamic libraries to the folder below this document.
            libassimp.3.dylib  libassimp.dylib






