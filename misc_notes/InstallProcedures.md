

The following assumes Windows 10 (will make a another section for Linux)

Delivery uses the D Language.

Delivery uses four software components: Compiler/linker, Package Manager, Git/Github and Editor.


***
Installing the compiler

D has three available compilers, but we will use the LLVM D compiler.  Available at  https://github.com/ldc-developers/ldc/releases
Download the Latest Release. LDC 1.16.0 at the time of this writing. Since we are assuming Windows 10, select ldc2-1.16.0-Windows-x64.7z

The LLVM compiler for D language is called LDC (LLCM D Compiler). This is for version 2 of the D Language so the command is actually named ldc2. 

***

Side Note: 7-zip file archiver

Note: this install procedure assumes you have the 7-Zip utility already installed. If not, go to https://www.7-zip.org/ and download either the 64 bit Windows 10 .exe or .msi installer.  Right click the downloaded application (7z1900-x64) and select "Run as Administrator".  7 zip must be installed as administrator. Keep things simple and just use the default destination folder C:Program Files\7-Zip\ and select [Install] button

We don't need to add a path in the PATH environment variable that points to this new location for 7-zip.exe because the Windows File Explorer automaticaly knows about 7 zip. 

***

Since ldc2-x.xx.0-Windows-x64.7z do not have a built-in installer, we'll have to manually massage it a bit.

Select the latest ldc2-x.xx.x-Windows-x64.7z and download it.

After the download is finished, right click the file --> 7-zip --> Extract Here

You should now see a folder created called ldc2-x.xx.x-Windows-x64.  You can now delete the .7z file.

***
Like dmd, ldc's directory structure in the compressed archive is good to go.
Extract into a directory and add it to your PATH variable.

For example here is my directory structure for both:

C:\development\D\dmd_2.087.0\windows\bin\dmd.exe
C:\development\D\ldc2-1.16.0-windows-multilib\bin\ldc2.exe
***

Now open a cmd window which should open to you %userprofile% env variable
```
Microsoft Windows [Version 10.0.14393]
(c) 2016 Microsoft Corporation. All rights reserved.

C:\Users\kheaser>mkdir D_development

C:\Users\kheaser>
```
Now with two Windows File Explores windows, cut the ldc2-x.xx.x-Windows-x64 folder and paste it into the C:\Users\<username>\D_development folder.

***

Now add this new path C:\Users\<username>\D_development\ldc2-x.xx.x-Windows-x64\bin to the PATH environment variable.

this can be done using Rapid Environment Editor standalone tool, or in the command line using SETX


***
Side Note about SETX

Set modifies the current shell's (window) environment values, and the change is available immediately, but it is temporary. The change will not affect other shells that are running, and as soon as you close the shell, the new value is lost until such time as you run set again.

setx modifies the value permenantly, which affects all future shells, but does not modify the environment of the shells already running. You have to exit the shell and reopen it before the change will be available, but the value will remain modified until you change it again.

setx PATH %PATH%;c:\my-user-specifc-bin-path or
Setx sets environment variables permanently. SETX can be used to set Environment Variables for the machine - all users (use /m option) or the currently logged on user (default).

***

```
setx PATH %PATH%;C:\Users\<username>\D_development\ldc2-x.xx.x-Windows-x64\bin

```

To verify that the compiler has been setup properly and all is well, open new cmd line window and type ldc2.
You should see lots of documentation on how to use it.

```
C:\Users\kheaser>ldc2
OVERVIEW: LDC - the LLVM D compiler

USAGE: ldc2 [options] files --run Runs the resulting program, passing the remaining arguments to it

OPTIONS:

General options:

  -D                                            - Generate documentation
  -Dd=<directory>                               - Write documentation file to <directory>
  -Df=<filename>                                - Write documentation file to <filename>
  -H                                            - Generate 'header' file
  -Hd=<directory>                               - Write 'header' file to <directory>
```
















To install on a Linux, specifically Ubuntu 10.0 machine.

Open terminal and

```
generic@generic-ThinkCentre-M93p:~$ ldc2

Command 'ldc2' not found, but can be installed with:

sudo apt install ldc

generic@generic-ThinkCentre-M93p:~$ dub

Command 'dub' not found, but can be installed with:

sudo apt install dub

generic@generic-ThinkCentre-M93p:~$ git

Command 'git' not found, but can be installed with:

sudo apt install git
```
Ubuntu is kind enough to tell us how to get each project 
So let's download and install them as noted.

```
sgeneric@generic-ThinkCentre-M93p:~$ sudo apt install ldc
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following NEW packages will be installed:
  ldc
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 0 B/2,826 kB of archives.
After this operation, 14.2 MB of additional disk space will be used.
Selecting previously unselected package ldc.
(Reading database ... 160620 files and directories currently installed.)
Preparing to unpack .../ldc_1%3a1.8.0-1_amd64.deb ...
Unpacking ldc (1:1.8.0-1) ...
Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
Setting up ldc (1:1.8.0-1) ...
```
Now verify that the version is the latest with the following.

```
generic@generic-ThinkCentre-M93p:~$ ldc2 --version
LDC - the LLVM D compiler (1.8.0):
  based on DMD v2.078.3 and LLVM 5.0.1
  built with LDC - the LLVM D compiler (0.17.5)
```
Install dub. 

```
generic@generic-ThinkCentre-M93p:~$ sudo apt install dub
Reading package lists... Done
Building dependency tree       
Reading state information... Done...
Unpacking dub (1.8.0-2) ...
Setting up default-d-compiler (0.5) ...
Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
Setting up dub (1.8.0-2) ...
generic@generic-ThinkCentre-M93p:~$ dub --version
DUB version 1.8.0-2, built on Mar 27 2018
```
Notice that this will be a out of date version.

```
generic@generic-ThinkCentre-M93p:~$ dub --version
DUB version 1.8.0-2, built on Mar 27 2018
```

It's 2019. Ubuntu's dub package is out of date. Let's grab a new one, but this time we'll use dub to update dub.

```
generic@generic-ThinkCentre-M93p:~$ dub fetch dub
Fetching dub 1.14.0...
Please note that you need to use `dub run <pkgname>` or add it to dependencies of your package to actually use/run it. dub does not do actual installation of packages outside of its own ecosystem.
```
Need to build the new version of dub.
```
generic@generic-ThinkCentre-M93p:~$ dub run dub
Building package dub in /home/generic/.dub/packages/dub-1.14.0/dub/
Fetching libevent 2.0.2+2.0.16 (getting selected version)...
Fetching diet-ng 1.4.3 (getting selected version)...
Fetching taggedalgebraic 0.10.8 (getting selected version)...
       o   o   o
Non-selected package mir-linux-kernel is available with version 1.0.1.
Package eventcore can be upgraded from 0.8.27 to 0.8.41.
Use "dub upgrade" to perform those changes.
Performing "debug" build using /usr/bin/ldc2 for x86_64.
dub 1.14.0: building configuration "application"...
Error: failed to locate gcc
/usr/bin/ldc2 failed with exit code 1.
```

Oops. Need gcc to build dub,

```
generic@generic-ThinkCentre-M93p:~$ sudo apt install gcc
   o  o  o
generic@generic-ThinkCentre-M93p:~$ sudo apt install curl
```

Building dependency tree       
Reading state information... Done
The following additional packages will be installed:
  gcc-7 libasan4 libatomic1 libc-dev-bin libc6-dev libcilkrts5 libgcc-7-dev libitm1 liblsan0 libmpx2 libquadmath0 libtsan0
  libubsan0 linux-libc-dev manpages-dev
Suggested packages:
  gcc-multilib make autoconf automake libtool flex bison gcc-doc gcc-7-multilib gcc-7-doc gcc-7-locales libgcc1-dbg libgomp1-dbg
  libitm1-dbg libatomic1-dbg libasan4-dbg liblsan0-dbg libtsan0-dbg libubsan0-dbg libcilkrts5-dbg libmpx2-dbg libquadmath0-dbg
  glibc-doc
The following NEW packages will be installed:
  gcc gcc-7 libasan4 libatomic1 libc-dev-bin libc6-dev libcilkrts5 libgcc-7-dev libitm1 liblsan0 libmpx2 libquadmath0 libtsan0
  libubsan0 linux-libc-dev manpages-dev
0 upgraded, 16 newly installed, 0 to remove and 0 not upgraded.
Need to get 16.8 MB of archives.
After this operation, 73.3 MB of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 http://us.archive.ubuntu.com/ubuntu bionic-updates/main amd64 libitm1 amd64 8.2.0-1ubuntu2~18.04 [28.1 kB]
Get:2 http://us.archive.ubuntu.com/ubuntu bionic-updates/main amd64 libatomic1 amd64 8.2.0-1ubuntu2~18.04 [9,064 B]
Get:3 http://us.archive.ubuntu.com/ubuntu bionic-updates/main amd64 l
```

GCC has bne


