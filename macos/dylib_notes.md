
This document explains how, when and where all the dynamic Mac OS libraries used in Deliver repository.

OpenGL3.0+
GLFW3

***

FreeImage
http://freeimage.sourceforge.net
brew install freeimage
==> Pouring freeimage-3.17.0_1.sierra.bottle.tar.gz
==> Using the sandbox
/usr/local/Cellar/freeimage/3.17.0_1: 12 files, 29.2MB
        
Created in /usr/local/lib and moved to folder below this document.
libfreeimage.3.17.0.dylib  libfreeimage.3.dylib  libfreeimage.dylib

***

FreeType
https://www.freetype.org
brew install freetype
==> Installing dependencies for freetype: libpng
==> Installing freetype dependency: libpng
==> Pouring libpng-1.6.29.sierra.bottle.tar.gz
==> Using the sandbox
/usr/local/Cellar/libpng/1.6.29: 26 files, 1.2MB       

Created in /usr/local/lib and moved to folder below this document.
libfreetype.6.dylib  libfreetype.dylib

***
SDL2 (Simple DirectMedia Layer) 
```
$brew install sdl2
==> Pouring sdl2-2.0.7.high_sierra.bottle.tar.gz
/usr/local/Cellar/sdl2/2.0.7: 86 files, 3.9MB

$ brew install sdl2_mixer
==> Installing dependencies for sdl2_mixer: libmodplug, libogg, libvorbis
==> Installing sdl2_mixer dependency: libmodplug
==> Downloading https://homebrew.bintray.com/bottles/libmodplug-0.8.9.0.high_sie
######################################################################## 100.0%
==> Pouring libmodplug-0.8.9.0.high_sierra.bottle.tar.gz
🍺  /usr/local/Cellar/libmodplug/0.8.9.0: 15 files, 352.6KB
==> Installing sdl2_mixer dependency: libogg
==> Downloading https://homebrew.bintray.com/bottles/libogg-1.3.3.high_sierra.bo
######################################################################## 100.0%
==> Pouring libogg-1.3.3.high_sierra.bottle.tar.gz
🍺  /usr/local/Cellar/libogg/1.3.3: 97 files, 460.2KB
==> Installing sdl2_mixer dependency: libvorbis
==> Downloading https://homebrew.bintray.com/bottles/libvorbis-1.3.5_1.high_sier
######################################################################## 100.0%
==> Pouring libvorbis-1.3.5_1.high_sierra.bottle.tar.gz
🍺  /usr/local/Cellar/libvorbis/1.3.5_1: 159 files, 2.3MB
==> Installing sdl2_mixer
==> Downloading https://homebrew.bintray.com/bottles/sdl2_mixer-2.0.2_3.high_sie
######################################################################## 100.0%
==> Pouring sdl2_mixer-2.0.2_3.high_sierra.bottle.tar.gz
```


Moved from /usr/local/Cellar/sdl2/2.0.7/lib
libSDL2-2.0.0.dylib
libSDL2.dylib
to ~/Delivery/macos/dynamiclibraries 
      
Moved from /usr/local/Cellar/sdl2_mixer/2.0.2_3/lib
libSDL2_mixer-2.0.0.dylib	
libSDL2_mixer.dylib
to ~/Delivery/macos/dynamiclibraries 

***


    - Assimp

        brew install assimp
            ==> Pouring assimp-3.3.1.sierra.bottle.tar.gz
            ==> Using the sandbox
            /usr/local/Cellar/assimp/3.3.1: 55 files, 7.9MB        
            and move the following dynamic libraries to the folder below this document.
            libassimp.3.dylib  libassimp.dylib