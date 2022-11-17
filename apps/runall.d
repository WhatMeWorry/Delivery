

// runall.exe executable sits in the ..\Delivery\apps directory and will iterate through each
// project sub folder with xx_xx_project by:
//           1) change directory into that sub project
//           2) run dub command to build and then that project
//           3) change directory back into the apps directory 
//   

module runall;

import std.file : isDir, getcwd, dirEntries, SpanMode, chdir;
import std.stdio;
import std.algorithm.comparison : cmp;
import std.process : Config, spawnProcess, wait, spawnShell;
import std.regex: regex, matchFirst;

void main(char[][] args)
{
    string fixedLocation = getcwd();  // use this as a fixed location to use to find other files relative to this position.
	
    writeln("runall.exe is in present working directory: ", fixedLocation);
		
    // Iterate the current directory in breadth
    foreach (string dir; dirEntries("", SpanMode.shallow))
    {
        auto m = matchFirst(dir, regex(`^\d\d_`));  // \d\d matches any unicode digit at beginning of directory name

        if (isDir(dir) && !m.empty)   // must be a directory with name begining with: xx_ where x = [0..9]
        {
            writeln("Directory: ", dir);
            string binDir = dir;
			
            chdir(binDir); // go down into the project subdirectory
			
            writeln("present working subdirectory: ", getcwd());    
			
            version(Windows)  
            {
                //string compilePath = fixedLocation ~ `\..\windows\compilers_and_utilities\\`;
				
				// the --compiler argument can either be  path\to\compiler\<compiler> or just 
				// <compiler> where the path is defined in the PATH environment variable
				
				//string compiler = "dmd";  // gcc or ldc
                string compiler = `..\..\windows\compilers_and_utilities\dmd2\windows\bin64\dmd`;				
                auto pid = spawnShell(`..\duball.exe run --compiler="` ~ compiler ~ `" --arch=x86_64 --force`);				
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

            chdir("..");   // go up to the project      
        }
		
        string lineIn;
        writeln("Enter to continue");  
        readf(" %s\n", &lineIn);    // ← \n at the end
   
    }
}
