

The D Language, like other languages, has its own runtime library called [Phobos](https://dlang.org/phobos/index.html)

But there exists even more functionality in 3rd party libraries or **packages** as Dub calls them. Unlike Phobos, packages reside outside of the D Language and so must be explicitly connected with a D program. Will see how this is done shortly.

In short, DUB is the D package registry. It is also a command utility which allows D programs to easily incorporate DUB packages. 

The list of [Dub packages](https://code.dlang.org/) is extensive and always growing. Packages specilize in areas as diverse as File Systems, Graphical User Interfaces, Video, and Networking.

The are two main kinds of D pacakges: stand-alone applications or developmental libraries. Since Delivery itself consists of a collection of instructional programs, we will only be interested in the development libraries. There is even group of packages grouped as Candidates for inclusion in the D Standard Library; these are packages that, if eventually considered so useful and prevalent by the D community, will be rolled into Phobos officially. 

Since Delivery is primarily a tutorial about openGL3, we will need the [derelict-gl3](https://code.dlang.org/packages/derelict-gl3) package. Additionally, we will create a tutorial game where we will introduce images, sound, and text; This functionality, we can get through [derelict-sdl2](https://code.dlang.org/packages/derelict-sdl2)

How do we actually go about this?

I'm going to write a trivial, yet traditional, Hello World program.  I'll use dub to get us started.

```Batchfile
C:\>mkdir myprojects

C:\>cd myprojects

C:\myprojects>dub init HelloThenSound
Package recipe format (sdl/json) [json]: sdl
Name [hellothensound]:
Description [A minimal D application.]:
Author name [kheaser]:
License [proprietary]:
Copyright string [Copyright ┬⌐ 2018, kheaser]:
Add dependency (leave empty to skip) []:
Successfully created an empty project in 'C:\myprojects\HelloThenSound'.
Package successfully created in HelloThenSound
```
A new directory called HelloThenSound has been created.

```
C:\myprojects>dir

 Directory of C:\myprojects
01/04/2018  11:09 AM    <DIR>          HelloThenSound
```

A file called dub.sdl (or dub.json if you defaulted the above prompt: **Package recipe format (sdl/json) [json]:** has will be created with build information.  The .gitignore is a Github file which we can ignore for now.  And a new directory **source** has been created.

```
C:\myprojects>dir HelloThenSound

 Directory of C:\myprojects\HelloThenSound

01/04/2018  11:09 AM               172 .gitignore
01/04/2018  11:09 AM               140 dub.sdl
01/04/2018  11:09 AM    <DIR>          source
```

Let's look at what is in the source directory. It is called __source__ because here we will keep our source code.
 
``` 
C:\myprojects>dir HelloThenSound\source

 Directory of C:\myprojects\HelloThenSound\source

01/04/2018  11:09 AM                95 app.d
```

app.d is an D file consisting of D Language code. It is incredible trivial. But as every thousand mile journey begins with one step, app.d is our first step.  Open it up with your favorite editor and you should see:

```D
import std.stdio;

void main()
{
    writeln("Edit source/app.d to start your project.");
}
```

Using your text editor, change the output to 
```D
import std.stdio;

void main()
{
    writeln("Here we go", "\n");  // new line after Here we go  
    writeln("Hellow World - But where's the Sound?");
}
```

After saving off your changes, we will now use `dub run` command to compile, link, and run the program
```
C:\myprojects\HelloThenSound>dub run
Performing "debug" build using ldc2 for x86_64.
hellothensound ~master: building configuration "application"...
Running .\hellothensound.exe
Here we go

Hellow World - But where's the Sound?
```

You've now ran you first D program. But where is the sound.  Well, we didn't put any D code to make audio. And even if you looked through the entire D language or Phobos library, you would not find anything.  D, like COBOL, Fortran, C, C++, Java, Go, Rust, etc. doesn't have built-in support for sound.  Here is were 3rd party libraries come in, or in our case DUB packages.

You can go to [DUB](https://code.dlang.org/) website, and choose Select Category `Development Library` and `Audio Libraries` to show all the audio relevant packages. But instead, we are going to use the audio portion of a popular game package called [SDL](https://www.libsdl.org/). However, the D specific DUB package is called [derelict-sdl2](https://code.dlang.org/packages/derelict-sdl2) which has 
 which is often used for games. 
