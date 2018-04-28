```
import std.stdio;

void main()
{
    double[5] staticArray = 3.01;
    staticArray.writeln;
    
    int[] dynamicArray = [ 1, 2 ,3, 5];
    dynamicArray.writeln;   
}
```
Prints:
[3.01, 3.01, 3.01, 3.01, 3.01]
[1, 2, 3, 5]

--------------------------------------------------------------------------------------------

```
import std.stdio;

struct Foo(size_t n)
{
    double[n] bar = 3;
}
void main()
{
    import std.stdio;
    Foo!5 foo;
    writeln(foo.bar);  // prints "[0, 0, 0, 0, 0]"
}
```
Prints:
[3, 3, 3, 3, 3]


--------------------------------------------------------------------------------------------

Q: Suppose we have a function like this:

void diss(int[] array) ...

How can we detect if array is static (fixed size) or dynamic, inside the function body?

A: array here is always dynamic because it is not of a fixed size type.

--------------------------------------------------------------------------------------------

Static arrays are allocated on the stack
Static arrays point to memory on the stack, inside an aggregate type on the heap, or inside the static data area. In the stack case, you can use this strategy:


```
import std.algorithm, std.conv, std.stdio, core.thread;
    
bool isLocatedOnStack(T)(T[] arr) 
{
    auto top = thread_stackTop();
    writeln("top = ", top);    
    ulong intTop = cast(ulong) top;
    writeln("intTop = ", intTop);   
    
    auto bottom = thread_stackBottom();
    writeln("bottom = ", bottom);
    ulong intBot = cast(ulong) bottom;
    writeln("intBot = ", intBot);
    
    writeln("diff = ", top - bottom);
    
    return (arr.ptr >= min(top, bottom)) && (arr.ptr <= max(top, bottom));
}


void main()
{
    writeln("stack top ", thread_stackTop());
    writeln("stack bot ", thread_stackBottom());    
    int[7] staticArray = [2, 23, 4, 5, 9, 1, 66];
     
    writeln(isLocatedOnStack(staticArray)); 
  
    int[] dynamicArray = [55, 66, 77];
   
    writeln(isLocatedOnStack(dynamicArray)); 
    
}
```
--------------------------------------------------------------------------------------------

Note that static arrays are value types. So, if the parameter is int[3], then the argument will be copied. However, you can still take it by reference (with the ref keyword):

Enter example of really slow array copying... then use ref for speedup example

--------------------------------------------------------------------------------------------

Dynamic arrays are allocated on the heap.

The GC is easy to query, you can simply ask it with core.memory.GC.addrOf(p)
If p references memory not originally allocated by the garbage collector, if p is null, or if the garbage collector does not support this operation, null will be returned.

```
import std.stdio;
import core.memory;


void main()
{
    int[7] staticArray = [2, 23, 4, 5, 9, 1, 66];
   
    // (void)* addrOf(inout(void)* p)    
    writeln(GC.addrOf(staticArray.ptr));  // prints null (not in heap)
        
    int[] dynamicArray = [55, 66, 77];
   
     writeln(GC.addrOf(dynamicArray.ptr));  
}
```
Prints:

null
7FC1A171E000


Note: The append operator uses this kind of logic to determine if it is safe to append.

--------------------------------------------------------------------------------------------

 void diss(int[3] array) ...  //this expects a static array of size 3
 void diss(int[] array) ...  //this expects a dynamic array

is this correct?

Yes.

Note that static arrays are value types. So, if the parameter is int[3], then the argument will be copied. However, you can still take it by reference (with the ref keyword):

--------------------------------------------------------------------------------------------


```
import std.stdio;

void diss(int[3] array) 
{
    writeln(typeof(array).stringof);
}

void diss(int n)(int[n] array) 
{ 
    writeln(typeof(array).stringof);
}

void diss(int[] array) 
{
    writeln(typeof(array).stringof);
}



void main() 
{
    int[] ray;
    diss(ray);
    int[5] anySizeA;
    diss(anySizeA);
    int[7] anySizeB;
    diss(anySizeB);
}

Prints
int[]
int[5]
int[7]
```

Note: a call of { int[3] threeSize; diss(threeSize); } caused an error because it matches both func 1 and func 2.

--------------------------------------------------------------------------------------------


Also, if you need to append elements to an array inside of a function, then you need to mark function arguments as `ref`:

	void bar(ref int[] arr)

Code wouldn't compile if you try to pass static array as `ref` argument.

	Error: function f436.bar (ref int[] arr) is not callable using argument types (int[3])

static arrays cannot be passed as slice references because although there is an automatic slicing of static arrays, such slices are rvalues and rvalues cannot be bound to 'ref' parameters:


--------------------------------------------------------------------------------------------
                  THIS IS C++ 

The copy constructor is a constructor which creates an object by initializing it with an object of the same class, which has been created previously. The copy constructor is used to −

1 - Initialize one object from another of the same type.
2 - Copy an object to pass it as an argument to a function.
3 - Copy an object to return it from a function.


When is copy constructor called?
In C++, a Copy Constructor may be called in following cases: 
1. When an object of the class is returned by value.
2. When an object of the class is passed (to a function) by value as an argument.
3. When an object is constructed based on another object of the same class.
4. When compiler generates a temporary object.


If a copy constructor is not defined in a class, the compiler itself defines one. If the class has pointer variables and has some dynamic memory allocations, then it is a must to have a copy constructor. The most common form of copy constructor is shown here −
```
classname (const classname &obj) 
{
   // body of constructor
}
```
Here, obj is a reference to an object that is being used to initialize another object.

 Live Demo
```
#include <iostream>

using namespace std;

class Line {

   public:
      int getLength( void );
      Line( int len );          // simple constructor
      Line( const Line &obj);   // copy constructor
      ~Line();                  // destructor

   private:
      int *ptr;
};

// Member functions definitions including constructor
Line::Line(int len) {
   cout << "Normal constructor allocating ptr" << endl;
   
   // allocate memory for the pointer;
   ptr = new int;
   *ptr = len;
}

Line::Line(const Line &obj) {
   cout << "Copy constructor allocating ptr." << endl;
   ptr = new int;
   *ptr = *obj.ptr; // copy the value
}

Line::~Line(void) {
   cout << "Freeing memory!" << endl;
   delete ptr;
}

int Line::getLength( void ) {
   return *ptr;
}

void display(Line obj) {
   cout << "Length of line : " << obj.getLength() <<endl;
}

// Main function for the program
int main() {
   Line line(10);

   display(line);

   return 0;
}
```


--------------------------------------------------------------------------------------------
Q: Is it possible to call struct copy constructor explicitly, like in C++?

Well, technically, D doesn't even have copy constructors. Rather, structs can have postblit constructors. e.g.
```
struct S
{
    this(this)  // postblit constructor
    {
    }
}
```
In general, D tries to move structs as much as possible and not copy them. And when it does copy them, it does a bitwise copy of the struct and then runs the postblit constructor (if there is one) to mutate the struct after the fact to do stuff that needs to be done beyond a bitwise copy - e.g. if you want a deep copy of a member
```
struct S
{
    this(this)
    {
        if(i !is null)
            i = new int(*i);
    }

    int* i;
}
```
A copy constructor (in C++), on the other hand, constructs a new struct/class and initializes each member with a copy of the corresponding member in the struct/class being copied - or with whatever it's initialized with in the copy constructor's initializer list. It doesn't copy and then mutate like happens with D's postblit constructor. So, a copy constructor and a postblit constructor are subtly different.

One of the side effects of this is that while all structs/class in C++ have copy constructors (the compiler always generates one for you if you don't declare one), not all structs in D have postblit constructors. In fact, most don't. The compiler will generate one if the struct contains another struct that has a postblit constructor, but otherwise, it's not going to generate one, and copying is just going to do a bitwise copy. And, if there is no postblit construct, you can't call it implicitly or explicitly.

Now, if we compile this
```
struct A
{
}
pragma(msg, "A: " ~ __traits(allMembers, A).stringof);
```
it prints

A: tuple()
A has no members - be it member variables or functions. None have been declared, and the compiler has generated none.
```
struct B
{
    A a;
    string s;
}
pragma(msg, "B: " ~ __traits(allMembers, B).stringof);
```
prints

B: tuple("a", "s")
It has two members - the explicitly declared member variables. It doesn't have any functions either. Declaring member variables is not a reason for the compiler to generate any functions. However, when we compile
```
struct C
{
    this(this)
    {
        import std.stdio;
        writeln("C's postblit");
    }

    int i;
    string s;
}
pragma(msg, "C: " ~ __traits(allMembers, C).stringof);

```
it prints

C: tuple("__postblit", "i", "s", "__xpostblit", "opAssign")
Not only are its two member variables listed, but it also has __postblit (which is the explicitly declared postblit constructor) as well as __xpostblit and opAssign. __xpostblit is the postblit constructor generated by the compiler (more on that in a second), and opAssign is the assignment operator which the compiler generated (which is needed, because C has a postblit constructor).

```
struct D
{
    C[5] sa;
}
pragma(msg, "D: " ~ __traits(allMembers, D).stringof);
```
prints

D: tuple("sa", "__xpostblit", "opAssign")
Note that it has __xpostblit but not __postblit. That's because it does not have an explitly declared postblit constructor. __xpostblit was generated to call the postblit constructor of each of the member variables. sa is a static array of C's, and C has a postblit constructor. So, in order to copy sa properly, the postblit constructor for C must be called on each of the elements in sa. D's  __xpostblit does that. C also has __xpostblit, but it doesn't have any members with postblit constructors, so its __xposblit just calls its __postblit.

```
struct E
{
    this(this)
    {
        import std.stdio;
        writeln("E's postblit");
    }

    C c;
}
pragma(msg, "E: " ~ __traits(allMembers, E).stringof);
```
prints

E: tuple("__postblit", "c", "__xpostblit", "opAssign")
So, E - like C - has both __postblit and __xpostblit. __postblit is the explicit postblit constructor, and __xpostblit is the one generated by the compiler, However, in this case, the struct actually has member variables with a postblit constructor, so __xpostblit has more to do than just call __postblit.

If you had
```
void main()
{
    import std.stdio;
    C c;
    writeln("__posblit:");
    c.__postblit();
    writeln("__xposblit:");
    c.__xpostblit();
}
```
it would print

__posblit:
C's postblit
__xposblit:
C's postblit
So, there's no real difference between the two, whereas if you had

```
void main()
{
    import std.stdio;
    D d;
    writeln("__xposblit:");
    d.__xpostblit();
}
```

it would print

__xposblit:
C's postblit
C's postblit
C's postblit
C's postblit
C's postblit
Notice that C' postblit gets called 5 times - once for each element in D's member, sa. And we couldn't call __postblit on D, because it doesn't have an explicit postblit constructor - just the implicit one.

```
void main()
{
    import std.stdio;
    E e;
    writeln("__posblit:");
    e.__postblit();
    writeln("__xposblit:");
    e.__xpostblit();
}
```
would print

__posblit:
E's postblit
__xposblit:
C's postblit
E's postblit
And in this case, we can see that __postblit and __xpostblit are different. Calling __postblit just calls the explicitly declared postblit constructor, whereas __xpostblit calls it and the postblit constructors of the member variables.

And of course, since, A and B don't have posblit constructors and no members that have them, it would be illegal to call either __postblit or __xpostblit on them.

So, yes, you can call the postblit constructor explicitly - but only if it has one, and you almost certainly shouldn't be calling it. If a function starts with __, or it's one of the overloaded operators (and thus starts with op), then it almost never should be called explicitly - and that includes the postblit constructor. But if you do find a legitimate reason to call it, remember that you're probably going to want to call __xpostblit rather than __postblit, otherwise the postblit for the member variables won't be run. You can test for it by doing __traits(hasMember, S1, "__xpostblit") or by using the badly named hasElaborateCopyConstructor from std.traits (most code should use hasElaborateCopyConstructor, since it's more idiomatic). If you want to call __postblit for some reason, you'll need to test for it with __traits rather than std.traits though, because pretty much nothing outside of druntime cares whether a type declared __postblit. The stuff that does care about posblit constructors cares about __xpostblit, since that can exist whether __postblit was declared or not.


D doesn't have copy constructors per se, but you could call the implicit constructor with the contents of the existing one (which would create a shallow copy at least) with

foo(f.tupleof).bar()
The f.tupleof gives the list of struct members in a form that is suitable for automatic expansion to a function argument list.

--------------------------------------------------------------------------------------------

```
import std.stdio;

void main()
{
    int[] dyn = new int[9];
    auto dyn1 = new int[9];
    int[] dyn2 = new int[](9);  // newer syntax
    auto dyn3 = new int[](9);  
    
    int[7] sta;
    // auto sta1 = int[7];  // doesn't compile
                            // One of my D books mentions this syntax.    
    int[]*[1000] large;
    
    foreach(i, elem; large)
    {
        writeln("i = ", i);
        int[] temp = new int[](999);
        large[i] = &temp;      
    }
    // temp is a dynamic array (Reference Variable). So by it's very nature it uses indirection so I try
    // large[i] = temp;    
    // onlineapp.d(20): Error: cannot implicitly convert expression temp of type int[] to int[]*   
    
    // Ok, then I remember that dynamic arrays have that meta data stuff with a size and a pointer.  So I jump at
    // large[i] = temp.ptr;
    // onlineapp.d(20): Error: cannot implicitly convert expression cast(int*)temp of type int* to int[]*  
    
    // Finally I use large[i] = &temp;  which works, but it seems rather C/C++ like so I have a bad taste in my mouth.
    // And I feel like I really don't know what the hell I'm doing.
}
```

--------------------------------------------------------------------------------------------

```
Surely a stupid mistake on my part, but why is the first array repeated?


import std.stdio;

void main()
{
    int[]*[2] a;  // a static arrray holding pointers to dynamic arrays

    static int unique = 0;

    foreach(i, elem; a)
    {
        int[] temp = new int[](5);
        foreach(ref element; temp)
        {
            element = unique;
            unique++;
        }
        writeln("temp = ", temp);
        a[i] = &temp;
    }

    foreach(i, elem; a)
    {
            writeln(a[i].length);
            writeln("[", i, "][]", *a[i]);
    }
}
```

temp = [0, 1, 2, 3, 4]
temp = [5, 6, 7, 8, 9]
5
[0][][5, 6, 7, 8, 9]
5
[1][][5, 6, 7, 8, 9]

why is the first array repeated?

You're taking the address of a local variable and persisting it beyond the variable's scope. This is not safe in general; compilers regularly reuse spaces on the stack. DMD specifically tends to do this reliably with foreach loop bodies.


In addition to what Neia said, you shouldn't use pointers to dynamic arrays. Such things are really hard to allocate on the heap, since new int[] just makes an array, not a pointer to an array. You're way more likely to accidentally store pointers to stack variables (as demonstrated).

The only way 2 ways I know of to do it are to a) allocate a multi-dimensional array, and take it's pointer (e.g. (new int[][1]).ptr) or b) create a dummy struct with an array in it, and new that:

Struct Dummy { int[] array; }

auto p = new Dummy;
auto ptr = &p.array;

Just use int[][2] a, you will be better off.

--------------------------------------------------------------------------------------------

```
import std.stdio;

void main()
{
    int[][3] a;  // a static arrray holding pointers to dynamic arrays

    static int unique = 0;

    foreach(i, elem; a)
    {
        int[] temp = new int[](5);
        foreach(ref element; temp)
        {
            element = unique;
            unique++;
        }
        a[i] = temp;
    }

    foreach(i, elem; a)
    {
            writeln("[", i, "][]", a[i]);
    }
}

Prints
[0][][0, 1, 2, 3, 4]
[1][][5, 6, 7, 8, 9]
[2][][10, 11, 12, 13, 14]
```


--------------------------------------------------------------------------------------------

```
import std.stdio;
import std.random;

size_t dynamicMax = 100_000;    // 1_000_000 causes a memory allocation error
const size_t staticMax = 10_000;  // 100_000 does no compile

void main()
{
    int[][staticMax] a;  // a static arrray holding pointers to dynamic arrays

    static int unique = 0;

    foreach(i, elem; a)
    {
        int[] temp = new int[](dynamicMax);
        foreach(ref element; temp)
        {
            element = unique;
            unique++;
        }
        a[i] = temp;
    }

    auto rnd = Random(42);  // seed a random generator with a constant
    
    // Generate a uniformly-distributed integer in the range [0, dynamicMax-1]
    // If no random generator is passed, the global `rndGen` would be used
    
    foreach(i, elem; a)
    {
	        auto j = uniform(0, dynamicMax, rnd);	    
            writeln("[", i, "][", j, "] = ", a[i][j] );
    }
}

Prints
  . . .
  . . .
[9993][28901] = 999328901
[9994][76304] = 999476304
[9995][88941] = 999588941
[9996][75768] = 999675768
[9997][32152] = 999732152
[9998][93308] = 999893308
[9999][82790] = 999982790
myapp exited with code 0
```



--------------------------------------------------------------------------------------------

