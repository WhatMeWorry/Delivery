

import std.stdio;
import std.random;

size_t dynamicMax = 100_000;    // 1_000_000 causes a memory allocation error
const size_t staticMax = 10_000;  // 100_000 does not compile


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
        //auto j = uniform(0, dynamicMax, rnd);	    
        //writeln("[", i, "][", j, "] = ", a[i][j] );
    }
	
    writeln("first element = ");
    writeln("a[0][0] = ", a[0][0] );
    writeln("last element = ");
    writeln("[", staticMax-1, "][", dynamicMax-1 , "] = ", a[staticMax-1][dynamicMax-1] );    
}