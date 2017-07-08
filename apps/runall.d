

module runall;

import std.file : isDir, getcwd, dirEntries, SpanMode, chdir;
import std.stdio;
import std.algorithm.comparison : cmp;
import std.process : Config, spawnProcess, wait, spawnShell;

void main(char[][] args)
{
    writeln("present working directory: ", getcwd());
    // Iterate the current directory in breadth
    foreach (string i; dirEntries("", SpanMode.shallow))
    {
        writeln(i);
        if (isDir(i))
        {
            writeln("Directory: ", i);
            //string binDir = i ~ `\source`;
            string binDir = i;
            chdir(binDir);                       // go down into the subdirectory
            writeln("present working subdirectory: ", getcwd());                  
            //foreach (string j; dirEntries("", SpanMode.shallow))
            //{
                //writeln("               ", j);   
                //string s = i ~ ".exe"; 
                //writeln("s = ", s); 
                //if (cmp(s,j) == 0)
                {
				    //string execFile = i ~ `.exe`;
                    //writeln(execFile, " is the executable ");
					
                    /+
                    auto pid = spawnProcess(`..\duball.exe run --verbose --arch=x86_64 --force`,
                               std.stdio.stdin,
                               std.stdio.stdout,
                               std.stdio.stderr,
                               null,
                               Config.none,
                               null);
					+/
                    version(Windows)  
                    {
                        auto pid = spawnShell(`..\duball.exe run --arch=x86_64 --force`);    
                    } 
                    else  // OSX or Linux
                    {
                        auto pid = spawnShell(`../duball run --arch=x86_64 --force`);
                    }          
                    
                    wait(pid);
                    scope(exit)
                    {
                        auto exitCode = wait(pid);
                        writeln("myapp exited with code ", exitCode);
                    }        
                }				
            //}
            chdir("..");
 		
            
        }
		
    }
	
}
