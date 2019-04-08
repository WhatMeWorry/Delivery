
## Dub Notes


***

A brand new system with no dub packages
```
C:\>dub list
Packages present in the system and known to dub:
```

***

After deciding on the package you want, use the dub fetch command to download it.
the cache options may be either __user__, __system__ or __local__ 
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
