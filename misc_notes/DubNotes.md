
## Dub Notes


#### Where does Dub store local copies of packages 

By default, Dub on Microsoft Windows downloads copies of packages to
C:\Users\<username>\AppData\Roaming\dub\packages\

```
C:\Users\kheaser\AppData\Roaming\dub\packages>dir

 Directory of C:\Users\kheaser\AppData\Roaming\dub\packages

11/07/2017  11:44 AM    <DIR>          derelict-glfw3-3.1.3
01/02/2018  03:12 PM    <DIR>          derelict-sdl2-2.1.4
11/08/2017  12:41 PM    <DIR>          derelict-util-2.0.6
11/07/2017  11:49 AM    <DIR>          derelict-util-2.1.0
11/07/2017  12:50 PM    <DIR>          gl3n-1.3.1
```

***

A brand new system with no dub packages
```
C:\>dub list
Packages present in the system and known to dub:
```

***

After deciding on the package you want, use the dub fetch command to download it.

```
C:\>dub fetch derelict-sdl2
Fetching derelict-sdl2 2.1.4...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.

C:\>dub list
Packages present in the system and known to dub:
  derelict-sdl2 2.1.4: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
```
The package has been downloded to the new default directory called **\dub\packages\**

***

If you want to use your own path, 
```
C:\>mkdir dublocal

C:\>cd dublocal

C:\dublocal>dub fetch derelict-sdl2 --cache=local
Fetching derelict-sdl2 2.1.4...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.
```
`dub list` won't show the new package, yet. Need to add it to the registry with:

```
C:\dublocal>dir

01/03/2018  01:00 PM    <DIR>          .
01/03/2018  01:00 PM    <DIR>          ..
01/03/2018  01:00 PM    <DIR>          derelict-sdl2-2.1.4
01/03/2018  01:00 PM                 0 dub
```
Need to explicitly add it to the registry with:

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
```

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
cd C:\Users\kheaser\AppData\Roaming
rd /s /q dub

dub list
Packages present in the system and known to dub:

```
***

```
C:\>dub fetch derelict-sdl2
Fetching derelict-sdl2 2.1.4...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.

C:\>dub list
Packages present in the system and known to dub:
  derelict-sdl2 2.1.4: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-sdl2-2.1.4\derelict-sdl2\
```

***

have very simple dub.sdl with just:

dependency "derelict-util"  version="~>2.0.6"
dependency "derelict-glfw3" version="~>3.1.0"

Using dub registry url 'http://code.dlang.org/'
Refreshing local packages (refresh existing: true)...

Looking for local package map at C:\ProgramData\dub\packages\local-packages.json
Looking for local package map at C:\Users\kheaser\AppData\Roaming\dub\packages\local-packages.json

Note: Failed to determine version of package 00_01_print_ogl_ver at .. Assuming ~master.
Refreshing local packages (refresh existing: false)...

Looking for local package map at C:\ProgramData\dub\packages\local-packages.json
Looking for local package map at C:\Users\kheaser\AppData\Roaming\dub\packages\local-packages.json

  Missing dependency derelict-util 2.0.6 of 00_01_print_ogl_ver
  Missing dependency derelict-glfw3 3.1.3 of 00_01_print_ogl_ver   * 3.1.0 above
Refreshing local packages (refresh existing: false)...

Looking for local package map at C:\ProgramData\dub\packages\local-packages.json
Looking for local package map at C:\Users\kheaser\AppData\Roaming\dub\packages\local-packages.json

  Missing dependency derelict-util 2.0.6 of 00_01_print_ogl_ver
  Missing dependency derelict-glfw3 3.1.3 of 00_01_print_ogl_ver
Checking for missing dependencies.

Using fixed selection derelict-util 2.0.6
Using fixed selection derelict-glfw3 3.1.3

Fetching derelict-util 2.0.6 (getting selected version)...
Downloading from 'http://code.dlang.org/packages/derelict-util/2.0.6.zip'
Placing to C:\Users\kheaser\AppData\Roaming\dub\packages\...

Fetching derelict-glfw3 3.1.3 (getting selected version)...
Downloading from 'http://code.dlang.org/packages/derelict-glfw3/3.1.3.zip'
Placing to C:\Users\kheaser\AppData\Roaming\dub\packages\...

Refreshing local packages (refresh existing: false)...
Looking for local package map at C:\ProgramData\dub\packages\local-packages.json
Looking for local package map at C:\Users\kheaser\AppData\Roaming\dub\packages\local-packages.json
  Found dependency derelict-util 2.0.6
  Found dependency derelict-glfw3 3.1.3
Checking for upgrades.

Search for versions of derelict-util (1 package suppliers)

Return for derelict-util: [2.1.0, 2.0.6, 2.0.5, 2.0.4, 2.0.3, 2.0.2, 2.0.1, 2.0.0, 1.9.1, 1.9.0, 1.0.3, 1.0.2, 1.0.1, 1.0.0, 3.0.0-beta.2, 3.0.0-beta.1, 3.0.0-alpha.2, 3.0.0-alpha.1, ~master, ~3.0, ~2.1, ~2.0]

Search for versions of derelict-glfw3 (1 package suppliers)

Return for derelict-glfw3: [3.1.3, 3.1.2, 3.1.1, 3.1.0, 3.0.1, 3.0.0, 2.0.0, 1.1.1, 1.1.0, 1.0.2, 1.0.1, 1.0.0, 4.0.0-beta.1, 4.0.0-alpha.6, 4.0.0-alpha.5, 4.0.0-alpha.4, 4.0.0-alpha.3, 4.0.0-alpha.2, 4.0.0-alpha.1, ~master, ~dglfw-v3.2, ~4.0, ~3.2-b, ~3.2, ~3.1-static, ~3.1, ~3.0]

Caching upgrade results...

C:\Users\kheaser\OneDrive for Business\GitHub\Delivery\apps\00_01_print_ogl_ver>dub list
Packages present in the system and known to dub:
  00_01_print_ogl_ver ~master: C:\Users\kheaser\OneDrive for Business\GitHub\Delivery\apps\00_01_print_ogl_ver\
  derelict-glfw3 3.1.3: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\
  derelict-util 2.0.6: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-util-2.0.6\derelict-util\
















I've got a "Hello World" D program.  With the following dub.sdl


dependency "derelict-util"  version="~>2.0.6"
//dependency "derelict-glfw3" version="~>3.1.0"
dependency "derelict-gl3"   version="~>1.0.19"
dependency "derelict-fi"    version="~>2.0.3"
dependency "derelict-ft"    version="~>1.1.2"
dependency "derelict-al"    version="~>1.0.1"
dependency "derelict-fmod" version="~>2.0.4"
//dependency "derelict-assimp3" version="~>1.3.0"

This compiles and links fine and prints out Hello World!


However, when I uncomment the derelict-glfw3 line, I get

Using dub registry url 'http://code.dlang.org/'
Looking for local package map at C:\Users\kheaser\AppData\Roaming\dub\packages\local-packages.json
  Found dependency derelict-al 1.0.3
    Found dependency derelict-util 2.0.6
  Found dependency derelict-fmod 2.0.4
  Found dependency derelict-fi 2.0.3
  Found dependency derelict-glfw3 3.1.3    *(specified 3.1.0, not 3.1.3)
  Found dependency derelict-ft 1.1.3
  Found dependency derelict-gl3 1.0.23

LINK : fatal error LNK1104: cannot open file '..\..\..\..\..\AppData\Roaming\dub\packages\derelict-glfw3-3.1.3\derelict-glfw3\.dub\build\derelict-glfw3-dynamic-$DFLAGS-windows-x86_64-ldc_2074-CAF77735C9072B00A4BACA43B90429A3\DerelictGLFW3.lib'
Error: C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.10.25017\bin\HostX64\x64\link.exe failed with status: 1104
FAIL .dub\build\application-$DFLAGS-windows-x86_64-ldc_2074-1CCF55741BEB83AFD497E183B7504AC4\ 00_01_print_ogl_ver executable
ldc2 failed with exit code 1104.


And when I uncomment the derelict-assimp3 line, I get

LINK : fatal error LNK1104: cannot open file '..\..\..\..\..\AppData\Roaming\dub\packages\derelict-assimp3-1.3.0\derelict-assimp3\.dub\build\library-$DFLAGS-windows-x86_64-ldc_2074-B7525DDFF60E7B732C9FFF8001B1A781\DerelictASSIMP3.lib'
Error: C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Tools\MSVC\14.10.25017\bin\HostX64\x64\link.exe failed with status: 1104
FAIL .dub\build\application-$DFLAGS-windows-x86_64-ldc_2074-894CFE3403BE7E3436B42C7709041C78\ 00_01_print_ogl_ver executable
ldc2 failed with exit code 1104.


--------------------------- Copying Dub packages to default location (Fetching) -------------------------------------------

dub fetch <package>   will down load <package> with the "Last update" version to the default
directory C:\Users\<user>\AppData\Roaming\dub\packages\<package+version>\<package>\

A entry is also made in the package table with tuple package name, version, and location which
can be displayed with a dub list.

C:\>dub fetch derelict-util
Fetching derelict-util 2.1.0...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.

C:\>dub list
Packages present in the system and known to dub:
  derelict-util 2.1.0: C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-util-2.1.0\derelict-util\

  
------------------------ Copying Dub packages to user specified location (Fetching)- -----------------------------------------------

The C:\Users\<user>\AppData\Roaming\dub\packages\<package+version>\<package>\ directory should be thought
of as the remote 

dub fetch <package>    brings the software down from dub registry at 'http://code.dlang.org/'.
--cache=local          and copies it to the current working directory.

C:\>c:
C:\>cd \
C:\>mkdir dub
C:\>cd dub

C:\dub>dub fetch derelict-al --cache=local
Fetching derelict-al 1.0.3...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem. 

[dub list won't show the new package, yet. Need to add it to the registry with:]

C:\dub>dub add-local .\derelict-al-1.0.3\derelict-al
Registered package: derelict-al (version: 1.0.3)  

C:\dub>cd ..

C:\>dub list
Packages present in the system and known to dub:
  derelict-al 1.0.3: C:\dub\derelict-al-1.0.3\derelict-al\
  
  

  
---------------------------- Deleting Packages ------------------------------------------

Non-Local

dub remove <package>   delete the software in directory C:\Users\<user>\AppData\Roaming\dub\packages\<package+version>\<package>\ and remove the entry in the package table.

C:\>dub remove derelict-util
Removing derelict-util in C:\Users\kheaser\AppData\Roaming\dub\packages\derelict-util-2.1.0\derelict-util\
Removed package: 'derelict-util'
Removed derelict-util, version 2.1.0.

C:\>dub list
Packages present in the system and known to dub:


Local

Assume existing package registry on client of:

C:\>dub list
Packages present in the system and known to dub:
  derelict-al 1.0.3: C:\dub\derelict-al-1.0.3\derelict-al\

C:\>dub remove-local C:\dub\derelict-al-1.0.3\derelict-al\
Deregistered package: derelict-al (version: 1.0.3)

C:\>dub list
Packages present in the system and known to dub:
 

-----------------------------------------------------------------------------------------




C:\>cd dub

C:\dub>dub fetch --cache=local derelict-util --version=2.0.6
Fetching derelict-util 2.1.0...

C:\dub>dub fetch --cache=local derelict-glfw3
Fetching derelict-glfw3 3.1.3...

C:\dub>dub fetch --cache=local derelict-gl3
Fetching derelict-gl3 1.0.23...

C:\dub>dub fetch --cache=local derelict-fi
Fetching derelict-fi 2.0.3...

C:\dub>dub fetch --cache=local derelict-ft
Fetching derelict-ft 1.1.3...

C:\dub>dub fetch --cache=local derelict-al
Fetching derelict-al 1.0.3...

C:\dub>dub fetch --cache=local derelict-fmod --version=2.0.4
Fetching derelict-fmod 4.1.0...

C:\dub>dub fetch --cache=local derelict-assimp3
Fetching derelict-assimp3 1.3.0...

C:\dub>dub fetch --cache=local gl3n
Fetching gl3n 1.3.1...

C:\dub>dub list
Packages present in the system and known to dub:


C:\dub>dir
 Volume in drive C is Windows
 Volume Serial Number is 58DB-E6FD

 Directory of C:\dub

11/07/2017  12:37 PM    <DIR>          .
11/07/2017  12:37 PM    <DIR>          ..
11/07/2017  12:00 PM    <DIR>          derelict-al-1.0.3
11/07/2017  12:37 PM    <DIR>          derelict-assimp3-1.3.0
11/07/2017  12:36 PM    <DIR>          derelict-fi-2.0.3
11/07/2017  12:36 PM    <DIR>          derelict-fmod-4.1.0
11/07/2017  12:36 PM    <DIR>          derelict-ft-1.1.3
11/07/2017  12:36 PM    <DIR>          derelict-gl3-1.0.23
11/07/2017  12:36 PM    <DIR>          derelict-glfw3-3.1.3
11/07/2017  12:35 PM    <DIR>          derelict-util-2.1.0
               0 File(s)              0 bytes
11/07/2017  12:51 PM    <DIR>          gl3n-1.3.13n 
              10 Dir(s)  174,088,273,920 bytes free

C:\dub>dub add-local .\derelict-al-1.0.3\derelict-al
Registered package: derelict-al (version: 1.0.3)
C:\dub>dub add-local .\derelict-assimp3-1.3.0\derelict-assimp3
Registered package: derelict-assimp3 (version: 1.3.0)
C:\dub>dub add-local .\derelict-fi-2.0.3\derelict-fi
Registered package: derelict-fi (version: 2.0.3)
C:\dub>dub add-local .\derelict-fmod-2.0.4\derelict-fmod
Registered package: derelict-fmod (version: 4.1.0)
C:\dub>dub add-local .\derelict-ft-1.1.3\derelict-ft
Registered package: derelict-ft (version: 1.1.3)
C:\dub>dub add-local .\derelict-gl3-1.0.23\derelict-gl3
Registered package: derelict-gl3 (version: 1.0.23)
C:\dub>dub add-local .\derelict-glfw3-3.1.3\derelict-glfw3
Registered package: derelict-glfw3 (version: 3.1.3)
C:\dub>dub add-local .\derelict-util-2.0.6\derelict-util
Registered package: derelict-util (version: 2.0.6)
C:\dub>dub add-local .\gl3n-1.3.1\gl3n
Registered package: gl3n (version: 1.3.1)


// Following is the packages and their versions that were downloaded locally

C:\dub>dub list
Packages present in the system and known to dub:
  derelict-al 1.0.3: C:\dub\derelict-al-1.0.3\derelict-al\
  derelict-assimp3 1.3.0: C:\dub\derelict-assimp3-1.3.0\derelict-assimp3\
  derelict-fi 2.0.3: C:\dub\derelict-fi-2.0.3\derelict-fi\
  derelict-ft 1.1.3: C:\dub\derelict-ft-1.1.3\derelict-ft\
  derelict-gl3 1.0.23: C:\dub\derelict-gl3-1.0.23\derelict-gl3\
  derelict-glfw3 3.1.3: C:\dub\derelict-glfw3-3.1.3\derelict-glfw3\
  gl3n 1.3.1: C:\dub\gl3n-1.3.1\gl3n\
  derelict-fmod 2.0.4: C:\dub\derelict-fmod-2.0.4\derelict-fmod\
  derelict-util 2.0.6: C:\dub\derelict-util-2.0.6\derelict-util\
  




























