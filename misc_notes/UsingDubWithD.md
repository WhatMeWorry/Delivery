

The D Language, like other languages, has its own runtime library called [Phobos](https://dlang.org/phobos/index.html)

But there exists even more functionality in 3rd party libraries or **packages** as Dub calls them. Unlike Phobos, packages reside outside of the D Language and so must be explicitly connected with a D program. Will see how this is done shortly.

The list of [Dub packages](https://code.dlang.org/) is extensive and always growing.

The are two main kinds of D pacakges: stand-alone applications or developmental libraries. Since Delivery itself consists of a collection of instructional programs, we will only be interested in the development libraries.

Since Delivery is primarily a tutorial about openGL3, we will need the [derelict-gl3](https://code.dlang.org/packages/derelict-gl3) package. Additionally, we will create a tutorial game where we will introduce images, sound, and text; This functionality, we can get through [derelict-sdl2](https://code.dlang.org/packages/derelict-sdl2)


