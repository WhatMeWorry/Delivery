
module mytoolbox;

import std.stdio;             // writeln()
import std.process;           // executeShell()
import std.traits;            // isDynamicArray!()
import std.math;
import std.algorithm.iteration;  // sum
import std.ascii;                // newline
import std.conv;                 // to



/+
This compile time function generates the glVertexAttr... commands like the following:

glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (0 * GLfloat.sizeof));
glEnableVertexAttribArray(0);
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (3 * GLfloat.sizeof));
glEnableVertexAttribArray(1);
glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (6 * GLfloat.sizeof));
glEnableVertexAttribArray(2);
+/

string defineVertexLayout(T)(T[] arr, bool normalization = false)
{
    auto s = sum(arr);
    auto offset = 0;
    string    cmd1 = `glVertexAttribPointer(`;
    string    cmd2 = `glEnableVertexAttribArray(`;
    string   comma = `,`;
    string closing = `);`;
    string guts;
    string accum;
    string normalStr;

    if (normalization)
        normalStr = "GL_TRUE";
    else 
        normalStr = "GL_FALSE";

    foreach(i, elem; arr)
    {
        guts = cmd1 ~
               to!string(i) ~ ", " ~ 
               to!string(elem) ~ ", GL_FLOAT, " ~
               normalStr ~ ", " ~
               to!string(s) ~ " * GLfloat.sizeof, cast(const(void)*) (" ~
               to!string(offset) ~ " * GLfloat.sizeof)" ~ closing ~ newline;

        cmd2 = "glEnableVertexAttribArray(" ~ to!string(i) ~ closing ~ newline;

        offset += elem;

        accum ~= guts ~ cmd2;
    }

    return (accum);
}



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
// The .sizeof Returns the size of the dynamic array reference, which is 8 in 32-bit builds 
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
    version(Windows)
    {  
        // pause command prints out
        // "Press any key to continue..."

        // auto ret = executeShell("pause");
        // if (ret.status == 0)
        //     writeln(ret.output);

        // The functions capture what the child process prints to both its standard output 
        // and standard error streams, and return this together with its exit code.
        // The problem is we don't have the pause return output until after the user
        // hits a key.

        writeln("Press any key to continue...");       
        executeShell("pause");  // don't bother with standard output the child returns

    }
    else // Mac OS or Linux
    {
        writeln("Press any key to continue...");
        executeShell(`read -n1 -r`);    // -p option did not work
    }
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