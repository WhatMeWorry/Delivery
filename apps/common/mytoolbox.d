
module mytoolbox;

import std.stdio;             // writeln()
import std.process;           // executeShell()
import std.traits;            // isDynamicArray!()
import std.math;





void printEnvVariable(string str)
{
    import std.process : environment;
	import std.algorithm.iteration;
	
    auto splitUpItems(string envVar)
    {
        version(linux)
            auto items = std.algorithm.iteration.splitter(envVar, ':');  // Linux uses colon
        else version(Windows)
            auto items = std.algorithm.iteration.splitter(envVar, ';');  // Windows uses semi-colons;
        else version(OSX)
             auto items = std.algorithm.iteration.splitter(envVar, ':');  // MacOS uses colon
        return items;
    }
	
    string eVar = environment[str];  // get the environment variable
    auto components = splitUpItems(eVar);
	
	writeln("\n", "The ", str,  " environment variable contains:");
    foreach(component; components)
        writeln("   ",component); 	
	
	
}



void myLog(alias symbol)()
{
    string equalSign = " = ";
    string preamble = __traits(identifier, symbol) ~ equalSign;
    writeln(preamble, symbol);
    // writeln(symbol.stringof ~ equalSign, symbol);  // .stringof is considered unsafe - used __traits
}


// "There is a special type of array which acts as a wildcard that can hold arrays of any kind, 
// declared as void[].  The .length of a void array is the length of the data in bytes, 
// rather than the number of elements in its original type.
//
// The .sizeof	Returns the size of the dynamic array reference, which is 8 in 32-bit builds 
// and 16 on 64-bit builds.
//
// This template function does not all fixed arrays because staticArray.sizeof returns the array 
// length multiplied by the number of bytes per array element.
//
// Used ubyte[] because the garbage collector generally will not scan ubyte[] arrays for pointers
//
// void[] arr = someArray;   // int[] implicitly converts to void[].

int arrayByteSize(T)(T someArray) if (isDynamicArray!(T))
{
    ubyte[] arr = cast(ubyte[]) someArray;
    return cast(int) arr.length;
}

int arrayByteSize(T)(T someArray) if (isStaticArray!(T))
{
    return someArray.sizeof;
}

alias bytes            = arrayByteSize;
alias sizeInBytes      = arrayByteSize;
alias arraySizeInBytes = arrayByteSize;
alias lengthInBytes    = arrayByteSize;


void writeAndPause(string s)
{
    writeln(s);
    writeln("--- Press any key to continue ---");
    executeShell("pause");
}


T toRadians(T)(T degrees)
{
    T radians = (degrees * (PI / 180.0));
    return(radians);
}


T toDegrees(T)(T radians)
{
    T degrees = (radians * (180.0 / PI));
    return(degrees);
}


void writeOnce(alias symbol)()
{
    static bool firstTime = true;
    if (firstTime)
    {
        firstTime = false;
        string str = __traits(identifier, symbol);
        writeln(str, symbol);
    }
}



void writeMultiple(alias symbol, int max)()
{
    static int count = 0;
    if (count < max)
    {
        count++;
        string str = __traits(identifier, symbol);
        writeln(str, symbol);
    }
}


bool hasThisFuncBeenCalledThisManyTimes(int times)
{
    static int counter = 0;  // only initialized/assigned 

    counter++;
    if (counter > times)
    {
        counter = 0;
        return true;
    }    
    return false;
}