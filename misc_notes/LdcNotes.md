
On the official D Language home page,
https://dlang.org/

The "Downloads" tab takes you to,
https://dlang.org/download.html

Under the LDC icon, there is a "Download" field which takes you to,
https://github.com/ldc-developers/ldc#installation

This author feels that the majority of people (i.e. ldc users as opposed to ldc develovers) would 
be better served if the "Download" field took one to,
https://github.com/ldc-developers/ldc/releases

Or at the very least, make it clearer when the "installation" page or "releases" page should be used.

FOR WINDOWS:

1)  How to Install LLVM D Compiler (LDC)
    These instructions assumes 7-zip is already installed. 7-zip is a free pack/extract/compress/decompress utility.

    Goto https://github.com/ldc-developers/ldc/releases
        Scroll to most recent release of the web page. As of October 2020, select the LDC 1.24.0 release.  Now download the 7-zip file ldc2-x.x.x-windows-x64.7z file. 
	Probably in your download filder. Now  
            	 
         Right Click the file --> 7-zip --> Extract here
	    
         A ldc2-1.xx.0-windows-x86_64\ folder will be created.
	 
	 Make a directory off the root called ldc
	 
```
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community>cd \
C:\>mkdir ldc
```

Now go to the ldc2-1.xx.0-windows-x86_64\ folder, copy all of its contents, and then paste into the ldc folder.

```
C:\>dir \ldc
 Volume in drive C is Windows
 Directory of C:\ldc
12/03/2019  01:33 PM    <DIR>          .
12/03/2019  01:33 PM    <DIR>          ..
10/16/2019  04:49 PM    <DIR>          bin
10/16/2019  04:47 PM    <DIR>          etc
10/16/2019  04:47 PM    <DIR>          import
10/16/2019  04:47 PM    <DIR>          lib
10/16/2019  04:47 PM            27,268 LICENSE
10/16/2019  04:47 PM             2,140 README.txt
```


```
C:\>ldc
'ldc' is not recognized as an internal or external command,
operable program or batch file.

C:\>setx PATH "%PATH%;C:\ldc\bin"
SUCCESS: Specified value was saved.
```
	    
    Must have Microsoft C++ 2015 or 2017 installed. If not, a even better option is to just install the standalone "Visual C++ Build Tools".	
 
    "The new Visual Studio Build Tools provides a lightweight option for installing the tools you need without requiring the Visual Studio IDE.  visit http://aka.ms/visualcpp"
 
    LDC relies on the MS linker and MSVCRT + WinSDK lib
			
2)  Goto https://www.visualstudio.com/downloads/?q=build+tool#build-tools-for-visual-studio-2017

    vs_buildtools_1599795229  (setup application)

    Under Other Tools and Frameworks
    Build Tools for Visual Studio 2017   These Build Tools allow you to
                                         build native and manage
                                         MSBuild-based applications without 
                                         requiring the Visual Studio IDE

    Leave all the default selected options as is.    

3)  Will be using cmd.exe window.  Added path to PATH env variable of 

    Set modifies the current shell's (window) environment values, and the change is available immediately, but it is temporary. The change will not affect other shells that are running, and as soon as you close the shell, the new value is lost until such time as you run set again.

    setx modifies the value permenantly, which affects all future shells, but does not modify the environment of the shells already running. You have to exit the shell and reopen it before the change will be available, but the value will remain modified until you change it again.
	
    setx PATH %PATH%;c:\my-user-specifc-bin-path
    or      
    Setx sets environment variables permanently. SETX can be used to set Environment Variables for the machine - all users (use /m option) or the currently logged on user (default).  
    
```    
C:\>setx PATH "%PATH%;C:\ldc\bin"

SUCCESS: Specified value was saved.
```

      
      
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

On a Ubuntu (Linux) machine got this problem.

generic@generic-M93p:~/Delivery/apps/00_01_print_ogl_ver$ ./../duball run --arch=x86_64 --compiler=ldc2 --verbose --force
bash: ./../duball: cannot execute binary file: Exec format error

generic@generic-M93p:~/Delivery/apps/00_01_print_ogl_ver$ cd ..
generic@generic-M93p:~/Delivery/apps$ file duball
duball: Mach-O 64-bit x86_64 executable, flags:<NOUNDEFS|DYLDLINK|TWOLEVEL|WEAK_DEFINES|BINDS_TO_WEAK|PIE|HAS_TLV_DESCRIPTORS>


Seems to be a Mac OS executable.

recompiled duball.d on this Ubuntu machine, and file returned ELF:

(dmd-2.085.0)generic@generic-M93p:~/Delivery/apps$ file duball
duball: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/l, for GNU/Linux 3.2.0, 



=============== Very Easy with  Ubuntu Linux ==================

SUDO APT INSTALL LDC is dangerous because it package may not be stale!!!!  Depends on voulunteers.

```
generic@generic-M93p:~$ sudo apt-get install ldc
Reading package lists... Done
Building dependency tree       
Reading state information... Done
ldc is already the newest version (1:1.8.0-1).
0 upgraded, 0 newly installed, 0 to remove and 110 not upgraded.

generic@generic-M93p:~$ ldc2 --version
LDC - the LLVM D compiler (1.14.0):
  based on DMD v2.084.1 and LLVM 7.0.1
  built with LDC - the LLVM D compiler (1.14.0)
  Default target: x86_64-unknown-linux-gnu
  Host CPU: haswell
  http://dlang.org - http://wiki.dlang.org/LDC
```

INSTEAD USE THE OFFICIAL INSTALLER...

```
mkdir -p ~/dlang && wget https://dlang.org/install.sh -O ~/dlang/install.sh

chmod +x install.sh

~/dlang/install.sh install ldc
Downloading https://dlang.org/d-keyring.gpg
################################################################################################################### 100.0%
Downloading https://dlang.org/install.sh
################################################################################################################### 100.0%
gpg: keybox '/home/generic/.gnupg/pubring.kbx' created
gpg: /home/generic/.gnupg/trustdb.gpg: trustdb created
The latest version of this script was installed as ~/dlang/install.sh.
It can be used it to install further D compilers.
Run `~/dlang/install.sh --help` for usage information.

Downloading and unpacking https://github.com/ldc-developers/ldc/releases/download/v1.14.0/ldc2-1.14.0-linux-x86_64.tar.xz
################################################################################################################### 100.0%
Using dub 1.13.0 shipped with ldc-1.14.0

Run `source ~/dlang/ldc-1.14.0/activate` in your shell to use ldc-1.14.0.
This will setup PATH, LIBRARY_PATH, LD_LIBRARY_PATH, DMD, DC, and PS1.
Run `deactivate` later on to restore your environment.
```

And Don't Forget to Activate your environment.

```
generic@generic-ThinkCentre-M93p:~/dlang$ source ~/dlang/ldc-1.14.0/activate
(ldc-1.14.0)generic@generic-ThinkCentre-M93p:~/dlang$ ldc2 --version
LDC - the LLVM D compiler (1.14.0):
  based on DMD v2.084.1 and LLVM 7.0.1
  built with LDC - the LLVM D compiler (1.14.0)
  Default target: x86_64-unknown-linux-gnu
  Host CPU: haswell
  http://dlang.org - http://wiki.dlang.org/LDC
```


=============== How to permanently alter the env variables, to make LDC Active in all terminals.

Install Nautilus Admin Tool

```
sudo apt install nautilus-admin

```
Open a new version of Files (Nautilus) and right clocking on a folder will show Open as Administrator
and right clocking on a file will show Edit as Administrator

When Activated, run
```
echo $PATH
/home/generic/dlang/ldc-1.14.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin
```

and place the path to the ldc compiler into /etc/environment file. Need to edit as admin.

PATH="/home/generic/dlang/ldc-1.14.0/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"

You will need to sign off and back on again for this new setting to take effect.






