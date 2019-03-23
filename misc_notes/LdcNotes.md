

On the official D Language home page,
https://dlang.org/

The "Downloads" tab takes you to,
https://dlang.org/download.html

Under the LDC icon, there is a "Download" field which takes you to,
https://github.com/ldc-developers/ldc#installation

This author feels that the majority of people (i.e. ldc users as opposed to ldc develovers) would 
be better served if the "Download" field took one to,
https://github.com/ldc-developers/ldc/releases

Or at the very least, make it clearer on when the "installation" page or "releases" page should
be used.


1)  Install LLVM D Compiler (LDC)

    Goto https://github.com/ldc-developers/ldc/releases
        Download  ldc2-1.5.0-win64-msvc.zip
            extract .zip file to a new folder on c: drive.  It will automatically make a folder called \ldc2-1.5.0-win64-mscv
			rename the folder to just ldc2 (to simplify step 4)
			
	No installation is required. Simply use the executables in the bin subfolder.

    Must have Microsoft C++ 2015 or 2017 installation, either via Visual Studio
    or the standalone "Visual C++ Build Tools".	
 
    "The new Visual Studio Build Tools provides a lightweight option for installing the tools you need without requiring the Visual Studio IDE.  visit http://aka.ms/visualcpp"
 
    LDC relies on the MS linker and MSVCRT + WinSDK lib
			
2)  Goto https://www.visualstudio.com/downloads/?q=build+tool#build-tools-for-visual-studio-2017

    vs_buildtools_1599795229  (setup application)

    Under Other Tools and Frameworks
    Build Tools for Visual Studio 2017   These Build Tools allow you to
                                         build native and manage
                                         MSBuild-based applications without 
                                         requiring the Visual Studio IDE

    Left all the default selected options as is.    

3)  Will be using cmd.exe window.  Added path to PATH env variable of 

    Set modifies the current shell's (window) environment values, and the change is available immediately, but it is temporary. The change will not affect other shells that are running, and as soon as you close the shell, the new value is lost until such time as you run set again.

    setx modifies the value permenantly, which affects all future shells, but does not modify the environment of the shells already running. You have to exit the shell and reopen it before the change will be available, but the value will remain modified until you change it again.
	
    setx PATH %PATH%;c:\my-user-specifc-bin-path
    or
    setx PATH "%PATH%;C:\ldc2\bin"

4)  Note: DUB is present in the c:\ldc2\bin folder as a convenience!






============================ DUB.SDL =================

name "00_01_print_ogl_ver"
description "A minimal D application."
authors "Kyle"
copyright "Copyright � 2017, Kyle"
license "proprietary"

dependency "derelict-util"  version="~>2.0.6"
dependency "derelict-glfw3" version="~>3.1.0"
dependency "derelict-gl3"   version="~>1.0.19"
dependency "derelict-fi"    version="~>2.0.3"
dependency "derelict-ft"    version="~>1.1.2"
dependency "derelict-al"    version="~>1.0.1"
dependency "derelict-assimp3" version="~>1.3.0"

sourceFiles "../common/derelict_libraries.d"
sourceFiles "../common/mytoolbox.d"

targetPath "./bin"

==========================================================================================

..\duball.exe run --force --compiler=ldc2 --arch=x86_64 --verbose



Generate target derelict-al      (staticLibrary C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-al-1.0.3\derelict-al\lib DerelictAL)
Generate target derelict-util    (staticLibrary C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\lib DerelictUtil)
Generate target derelict-assimp3 (staticLibrary C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\lib DerelictASSIMP3)
Generate target derelict-fi      (staticLibrary C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-fi-2.0.3\derelict-fi\lib DerelictFI)
Generate target derelict-ft      (staticLibrary C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\lib DerelictFT)
Generate target derelict-gl3     (staticLibrary C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\lib DerelictGL3)
Generate target derelict-glfw3   (staticLibrary C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\lib DerelictGLFW3)
Performing "$DFLAGS" build using ldc2 for x86_64.



derelict-util 2.0.6: building configuration "library"...
ldc2 -march=x86-64 
    -I..\ 
    -I..\common 
    -I..\common_game -lib 
    -of..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\.dub\build\library-$DFLAGS-windows-x86_64-ldc_20745BE81BCB31F223235883EA3A708726D0\DerelictUtil.lib 
    -w -oq -od=.dub/obj -d-version=Have_derelict_util 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source\derelict\util\exception.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source\derelict\util\loader.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source\derelict\util\sharedlib.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source\derelict\util\system.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source\derelict\util\wintypes.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source\derelict\util\xtypes.d -vcolumns

Copying target from C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-5BE81BCB31F223235883EA3A708726D0\DerelictUtil.lib 
                 to C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\libderelict-al 1.0.3: building configuration "library"...

ldc2 -march=x86-64 
    -I..\ 
    -I..\common 
    -I..\common_game -lib 
    -of..\..\..\..\..\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B7525DDFF60E7B732C9FFF8001B1A781\DerelictASSIMP3.lib 
    -w -oq -od=.dub/obj -d-version=Have_derelict_assimp3 -d-version=Have_derelict_util 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\source\derelict\assimp3\assimp.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\source\derelict\assimp3\types.d -vcolumns

Copying target from C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B7525DDFF60E7B732C9FFF8001B1A781\DerelictASSIMP3.lib 
                 to C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\libderelict-fi 2.0.3: building configuration "library"...

ldc2 -march=x86-64 
    -I..\ 
    -I..\common 
    -I..\common_game -lib 
    -of..\..\..\..\..\AppData\Roaming\dub\packages\derelict-fi-2.0.3\derelict-fi\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-BDF1B718E73B013877C42FB55E66D395\DerelictFI.lib 
    -w -oq -od=.dub/obj -d-version=Have_derelict_fi -d-version=Have_derelict_util 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-fi-2.0.3\derelict-fi\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-fi-2.0.3\derelict-fi\source\derelict\freeimage\freeimage.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-fi-2.0.3\derelict-fi\source\derelict\freeimage\functions.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-fi-2.0.3\derelict-fi\source\derelict\freeimage\types.d -vcolumns

ldc2 -march=x86-64 
    -I..\ 
    -I..\common 
    -I..\common_game -lib 
    -of..\..\..\..\..\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B8D2ADDD0FCAA568478A1EF96630AE62\DerelictFT.lib 
    -w -oq -od=.dub/obj -d-version=Have_derelict_ft -d-version=Have_derelict_util 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\source\derelict\freetype\ft.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\source\derelict\freetype\functions.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\source\derelict\freetype\types.d -vcolumns

Copying target from C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B8D2ADDD0FCAA568478A1EF96630AE62\DerelictFT.lib 
                 to C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\libderelict-gl3 1.0.23: building configuration "library"...

ldc2 -march=x86-64 
    -I..\ 
    -I..\common 
    -I..\common_game -lib 
    -of..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-A98357941B6042F84FFE15BA0F9C8457\DerelictGL3.lib 
    -w -oq -od=.dub/obj -d-version=Have_derelict_gl3 -d-version=Have_derelict_util 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\arb.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\cgl.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\constants.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\deprecatedConstants.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\deprecatedFunctions.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\ext.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\functions.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\gl.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\gl3.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\glx.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\glxext.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\internal.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\types.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\wgl.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source\derelict\opengl3\wglext.d -vcolumns

Copying target from C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-A98357941B6042F84FFE15BA0F9C8457\DerelictGL3.lib 
                 to C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\libderelict-glfw3 3.1.3: building configuration "derelict-glfw3-dynamic"...

ldc2 -march=x86-64 
    -I..\ 
    -I..\common 
    -I..\common_game -lib 
    -of..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\.dub\build\derelict-glfw3-dynamic-$DFLAGS-windows-x86_64-ldc_2074-CAF77735C9072B00A4BACA43B90429A3\DerelictGLFW3.lib 
    -w -oq -od=.dub/obj -d-version=Have_derelict_glfw3 -d-version=Have_derelict_util 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\source\derelict\glfw3\dynload.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\source\derelict\glfw3\glfw3.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\source\derelict\glfw3\package.d 
          ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\source\derelict\glfw3\types.d -vcolumns

Copying target from C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\.dub\build\derelict-glfw3-dynamic-$DFLAGS-windows-x86_64-ldc_2074-CAF77735C9072B00A4BACA43B90429A3\DerelictGLFW3.lib 
                 to C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\lib

00_01_print_ogl_ver ~master: building configuration "application"...

ldc2 -march=x86-64 
    -I..\ 
    -I..\common 
    -I..\common_game 
    -of.dub\build\application-$DFLAGS-windows-x86_64-ldc_2074-FE51C38B209A0583D12856C210FFE155\00_01_print_ogl_ver.exe 
    -w -oq -od=.dub/obj -d-version=Have_00_01_print_ogl_ver -d-version=Have_derelict_al -d-version=Have_derelict_util -d-version=Have_derelict_assimp3 -d-version=Have_derelict_fi  -d-  version=Have_derelict_ft -d-version=Have_derelict_gl3 -d-version=Have_derelict_glfw3 
        -Isource 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-al-1.0.3\derelict-al\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-fi-2.0.3\derelict-fi\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\source 
        -I..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\source 
        ..\common\derelict_libraries.d 
        ..\common\mytoolbox.d source\app.d 
        ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-al-1.0.3\derelict-al\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B3C723F91C4AF259F342B150EF8443BF\DerelictAL.lib 
        ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B7525DDFF60E7B732C9FFF8001B1A781\DerelictASSIMP3.lib 
        ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-ft-1.1.3\derelict-ft\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B8D2ADDD0FCAA568478A1EF96630AE62\DerelictFT.lib 
        ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-gl3-1.0.23\derelict-gl3\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-A98357941B6042F84FFE15BA0F9C8457\DerelictGL3.lib 
        ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\.dub\build\derelict-glfw3-dynamic-$DFLAGS-windows-x86_64-ldc_2074-CAF77735C9072B00A4BACA43B90429A3\DerelictGLFW3.lib 
        ..\..\..\..\..\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-5BE81BCB31F223235883EA3A708726D0\DerelictUtil.lib -vcolumns

LINK : fatal error LNK1104: cannot open file '..\..\..\..\..\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B7525DDFF60E7B732C9FFF8001B1A781\DerelictASSIMP3.lib'
Error: C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.10.25017\bin\HostX64\x64\link.exe failed with status: 1104
FAIL .dub\build\application-$DFLAGS-windows-x86_64-ldc_2074-FE51C38B209A0583D12856C210FFE155\ 00_01_print_ogl_ver executable
ldc2 failed with exit code 1104.
myapp exited with code 2
PS C:\Users\kheaser\OneDrive for Business\GitHub\Delivery\apps\00_01_print_ogl_ver>


 





