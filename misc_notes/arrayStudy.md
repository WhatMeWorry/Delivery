
Q: Suppose we have a function like this:

void diss(int[] array) ...

How can we detect if array is static (fixed size) or dynamic, inside the function body?

A: array here is always dynamic because it is not of a fixed size type.

--------------------------------------------------------------------------------------------

Static arrays are allocated on the stack
Static arrays point to memory on the stack, inside an aggregate type on the heap, or inside the static data area. In the stack case, you can use this strategy:



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

--------------------------------------------------------------------------------------------

Note that static arrays are value types. So, if the parameter is int[3], then the argument will be copied. However, you can still take it by reference (with the ref keyword):

Enter example of really slow array copying... then use ref for speedup example

--------------------------------------------------------------------------------------------

Dynamic arrays are allocated on the heap.

The GC is easy to query, you can simply ask it with core.memory.GC.addrOf(p)
If p references memory not originally allocated by the garbage collector, if p is null, or if the garbage collector does not support this operation, null will be returned.

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

Note: a call of { int[3] threeSize; diss(threeSize); } caused an error because it matches both func 1 and func 2.

--------------------------------------------------------------------------------------------


Also, if you need to append elements to an array inside of a function, then you need to mark function arguments as `ref`:

	void bar(ref int[] arr)

Code wouldn't compile if you try to pass static array as `ref` argument.

	Error: function f436.bar (ref int[] arr) is not callable using argument types (int[3])

static arrays cannot be passed as slice references because although there is an automatic slicing of static arrays, such slices are rvalues and rvalues cannot be bound to 'ref' parameters:
