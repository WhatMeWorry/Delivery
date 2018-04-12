

| __Class__  | __Reference Semantics__   unit of object encapsulation   |
| ------ | ------ |
| cookie cutter for creating objects. Like jig, template, or blueprint. |
| specific instances of classes are called objects |
| objects are created through the use of the keyword __new__ |
| they consist of: |
| 1) constants |
| 2) state/data/fields per-object by default, per-class with use of __static__ modifier |
| 3) methods/operations per-object by default, per-class with use of __static__ modifier |
|    |
| accessed with . (dot)  So object.someDataOrMethod for both per-object and per-class state and methods |
| static class state/methods can also be manipulated even if no objects exist through the class.someDataOrMethod syntax | 
| Objects are accessed via references. |
| references are linked to class objects. this reference is also called _bindings_  |
| Objects may only be accessed through the use of references |
| One or more references may be bound to an object.  |
| Objects that have no references is an error called memory leak |
| A reference may exist without an object but it should be set to null.  |
| References that are not null and not bound to any object is an error called dangling pointer |
| Objects once created will reside in the same place in memory forever until Garbage Collected |
| when using __object = new SomeClass__ , the compiler creates a default constructor which initializes the object. All fields use .init property |
| Customized constructors may be defined with a method named __this__ with no return type but as soon as a user specifies a constructor, the compiler default one is deactivated. In this case user must specify explicitly the default constructor  __this() {}__    |
| Copying references around just adds more references pointing to the same object;
the object itself is never actually duplicated. |

***
***
***
***
***
---
---
---
---







| __Struct__  | __Value Semantics *__  encapsulates data values |
| ------ | ------ |
| The D Programming Language says you can't define a default constructor this()?  |
| You can define a post-blit constructor this(this)  |
| No inheritence like classes and all its accompanying support syntax |
|



__*__ In theory. Sometimes it is necessary for structures to be passed as reference for performance reasons. But this should be done as a last resort. 








--------------------------------------------------------------------------------------------------------

Andrei 
The behavior of this(this). His work:

https://github.com/dlang/dmd/pull/8055
https://github.com/dlang/dlang.org/pull/2281
https://github.com/dlang/dlang.org/pull/2299

... reveals a puzzling array of behaviors. Sometimes the typechecking is wrong, too.

I think it's very important for us to have a simple, correct, and canonical way of defining structs in the D language that work with the language features: qualifiers, pure, safe, and nogc.

Once we have that, we can encapsulate desirable abstractions (such as @nogc safe collections that work in pure code), regardless of how difficult their implementations might be. It seems that currently this(this) does not allow us to do that.

I think the way to move forward is to deprecate this(this) entirely 
...
We're not removing it as much as evolving it: we define an alternate copying mechanism, and once that is in tip-top shape, we deprecate this(this).



--------------------------------------------------------------------------------------------------------

This is the tricky part, an it is where I have a hard time deciding which to use.  For example:
>
>     struct File {
>         private int fileno;
>         void read(ubyte[] buf) {
>             core.sys.posix.unistd.read(fileno, buf.ptr, buf.length);
>         }
>     }
>
> Why, or when, is the above preferable to the following?
>
>     struct File {
>         private int fileno;
>     }
>     void read(File f, ubyte[] buf)
>         core.sys.posix.unistd.read(f.fileno, buf.ptr, buf.length);
>     }
>
> I still haven't heard any fact-based, logical arguments that advise me on which style to use, and so far it seems to be just that -- a matter of style.

In this case i would say go with the method and not a non-member function. There are two reasons for this. First the method uses private state which is itself a good indicator. Second 'read' is an action of 'File'. This is encapsulation in action because you are defining logical actions to be performed on the state of a class. It's a well formed unit with associated behaviours.

It is confusing to think 'if this was a non-member function in the same module i can also access use the private state'. Yes that's true but just because you *can* access it, it doesn't mean you should! In fact you should have a very well defined reason for doing so.

Classes should nearly always be nouns and methods nearly always be verbs. Nearly always because there are always exceptions. For example i like to name methods which return bool's starting with 'is'. e.g. isOpen, isRunning, etc. The rule is follow encapsulation[1] as much as possible when designing classes.

I found accessing private state in a module is useful when *initialising* said state when constructing objects. In this case the module can act like a very helpful factory. In a recent project i have a rigid class design of an application and it's child windows. Other windows should be able to be opened and their id's generated automatically and internally. These id's are only available as read-only properties. One window in particular i needed to create with a specific non-generated id. I couldn't include this data in the constructor as i don't want anyone to control the id's but *i* needed to this one time. This case fitted well into the D module design and allowed me to create a window, override its private id and move on knowing that could not be tampered with by anything else. This design turned out to be very clean and without any baggage of a unnecessary setter methods or constructor parameter.

I used to be of the ilk that thought all programming could be done using only classes and designing everything in a very strict OOP way. D has broken that way of thinking in me purely because of things like UFCS and a module's private access to members. Now i understand that you can actually achieve a cleaner design by moving towards these things instead of having everything as a class. First and foremost you must try and achieve a good OOP design, this is essential. Then use UFCS and module private access features to keep things clean and simple.

Keep things logical, simple and straightforward.




Reasons off the top of my head not to make them module functions:

1. You can import individual symbols from modules. i.e.:

import mymodule: MyType;

If a large portion of your API is module-level functions, this means you have to either import the whole module, or the individual methods you plan to use.

2. You can get delegates to methods. You cannot get delegates to module functions, even if they are UFCS compatible.

3. There is zero chance of a conflict with another type's similarly named method.

4. It enforces the "method call" syntax. I.e. you cannot use foo(obj) call. This may be important for readability.

5. You can only use operator overloads via methods. D is different in this respect from C++.

6. The documentation will be grouped with the object itself. This becomes even more critical with the new doc layout which has one page per type.

Reasons to make them module functions:

1. You have more than one object in the same file which implements the method identically via duck typing.

2. You want to change how the 'this' type is passed -- in other words, you want to pass a struct by value or by pointer instead of by ref.

3. The complement to #1 in the 'against' list -- you want your module-level API to be selectively enabled!

4. Of course, if you are actually implementing in a different module, Scott Meyers' reasoning applies there.

You may recall that I am a big proponent of explicit properties because I think the ways of calling functions have strong implications to the reader, regardless of the functions. This is the same thing. I look at foo(x) much differently than x.foo().


