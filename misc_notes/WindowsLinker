Prepare Your Development Environment

Install the Windows SDK

To write a Windows program in C or C++, you must install the Microsoft Windows Software Development Kit (SDK) 
or a development environment that includes the Windows SDK, such as Microsoft Visual C++. The Windows SDK 
contains the headers and libraries necessary to compile and link your application. The Windows SDK also 
contains command-line tools for building Windows applications, including the Visual C++ compiler and linker. 
Although you can compile and build Windows programs with the command-line tools, we recommend using a 
full-featured development environment such as Microsoft Visual Studio


Set Include and Library Paths

After you install the Windows SDK, make sure that your development environment points to the Include and Lib folders, which 
contain the header and library files.

For Visual Studio, the Windows SDK includes a Visual Studio Configuration Tool. This tool updates Visual Studio to use the 
Windows SDK header and library paths. For more information about this tool, see the Windows SDK release notes 
(https://go.microsoft.com/fwlink/p/?linkid=182068). Alternatively, you can add the paths from Visual Studio. 
For more information, consult the Visual Studio help documentation.


Command line tools
To build a C/C++ project on the command line, Visual Studio provides these command-line tools:

CL
Use the compiler (cl.exe) to compile and link source code files into apps, libraries, and DLLs.

Link
Use the linker (link.exe) to link compiled object files and libraries into apps and DLLs.

MSBuild
Use MSBuild (msbuild.exe) and a project file (.vcxproj) to configure a build and invoke the toolset indirectly. 
This is equivalent to running the Build project or Build Solution command in the Visual Studio IDE. Running 
MSBuild from the command line is an advanced scenario and generally not recommended.


Use Rapid Environment Editor (free Download)


C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC\14.20.27508\bin\Hostx64\x64
has
link.exe
lib.exe
cl.exe


```
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC
\14.20.27508\bin\Hostx64\x64>DUMPBIN /EXPORTS freeimage.lib
Microsoft (R) COFF/PE Dumper Version 14.20.27508.1
Copyright (C) Microsoft Corporation.  All rights reserved.
Dump of file freeimage.lib
File Type: LIBRARY
     Exports
       ordinal    name
                  FreeImage_AcquireMemory
                  FreeImage_AdjustBrightness
                  FreeImage_AdjustColors
                        o   o   o
                  FreeImage_ZLibGUnzip
                  FreeImage_ZLibGZip
                  FreeImage_ZLibUncompress
  Summary
          C9 .debug$S
          14 .idata$2
          14 .idata$3
           8 .idata$4
           8 .idata$5
           E .idata$6  
 ```          
           
And this file size is:

```
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC
\14.20.27508\bin\Hostx64\x64>dir freeimage.lib

07/31/2018  01:23 PM            65,322 FreeImage.lib
               1 File(s)         65,322 bytes
```       

And I did the same for freeimage.lib version 3.17.0

```
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC
\14.20.27508\bin\Hostx64\x64>DUMPBIN /EXPORTS freeimage.lib
Microsoft (R) COFF/PE Dumper Version 14.20.27508.1
Copyright (C) Microsoft Corporation.  All rights reserved.

Dump of file freeimage.lib
File Type: LIBRARY
     Exports
       ordinal    name
                  FreeImage_AcquireMemory
                  FreeImage_AdjustBrightness
                  FreeImage_AdjustColors
                  FreeImage_AdjustContrast
                  FreeImage_AdjustCurve
                     o   o   o
                FreeImage_ZLibCRC32
                  FreeImage_ZLibCompress
                  FreeImage_ZLibGUnzip
                  FreeImage_ZLibGZip
                  FreeImage_ZLibUncompress

  Summary

          C9 .debug$S
          14 .idata$2
          14 .idata$3
           8 .idata$4
           8 .idata$5
           E .idata$6    
           
C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Tools\MSVC
\14.20.27508\bin\Hostx64\x64>dir freeimage.lib
03/15/2015  09:52 AM            63,592 FreeImage.lib
               1 File(s)         63,592 bytes
```

So Version 3.17.0 was size 63,592 bytes with 249 functions.
   Version 3.18.0 was size 65,322 butes with 255 functions.
   
This is expected since 3.18.0 naturally has more functionality than 3.17.0

