
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
The package has been downloded to the user directory **C:\\Users\\user\\AppData\\Roaming\\dub\\packages\\derelict-sdl2-2.1.4\\derelict-sdl2\\**

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

This system package has been downloded to the system directory **C:\\ProgramData\\dub\\packages\\derelict-sdl2-2.1.4\\derelict-sdl2\**


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




