

module envstudy;


import std.stdio;
import std.system;  // defines enum OS     OS os = OS.win64;
import std.algorithm.searching : endsWith, canFind, findSplit;
//static import std.algorithm.iteration;
import std.algorithm.iteration : splitter;
import std.algorithm.mutation: remove;
import std.process : Config, environment, executeShell, execute, spawnShell, spawnProcess, wait;
import std.string;
import std.file : getcwd;
import std.regex: regex, matchFirst;
import std.array: split, join;
import std.uni: isWhite, isControl;
import std.ascii: whitespace, isPrintable;
import std.exception: enforce;

auto splitUpPaths(string s)
{
    version(Windows)
        return s.split(";");   // Windows uses semi-colons;
    else version(linux)
        return s.split(':');   // Linux uses colon separator
}


auto joinUpPaths(string[] s)
{
    version(Windows)
        return s.join(";");   // Windows uses semi-colons;
    else version(linux)
        return s.join(':');   // Linux uses colon separator
}


void listPaths(string[] paths)
{
	// writeln("paths[0] = ", paths[0]);
    writeln("paths.length = ", paths.length);	
	// writeln("paths[$-1] = ", paths[$-1]);

    writeln("\n","The PATH env variable has paths:");
    foreach(i, path; paths)
    {
	    writef("%3d", i);   // right justify
        writeln("   ",path);
    }
    writeln("\n");	
}


// given an array of strings (paths), delete one of the elements (paths)

void deletePath(ref string[] paths)
{     
    uint i;
    char c = 'N';	
	
    writeln("Enter index number of path to delete");   
    readf(" %s", i);

    writeln("i = ", i);

    if ( (i < 0) || (i >= paths.length) )
    {
        writeln("Index is out or bounds.");
    }
    else
    {
        writeln("Index ", i, " with [", paths[i], "] will be deleted");
        writeln;
        writeln("Do you wish to continue? Y or y to proceed ");
        readf(" %s", c);
        if ((c == 'Y') || (c == 'y'))
        {
		    // paths.remove(i);   // compiles fine but does nothing
            paths = paths.remove(i);	

            //listPaths(paths);
			
			writeln("paths.length = ", paths.length);
			writeln("environment variables are inherited from parent process to child process.");
			writeln("After modifying them, you will have to restart your IDE, or terminal window,"); 
			writeln("in order for them to udpate.");
        } 		
		
    } 	

}



void addPath(ref string[] paths)
{
    string userStr;
	char c;
    writeln("Enter new path to add to PATH env variable");   
    readf(" %s\n", userStr);	
	
    //writeln("userStr = *", userStr, "*");

    paths ~= userStr;  // add new path to string array
	
    //listPaths(paths);	
	
	//string cmdLine = `setx PATH "` ~ userStr ~ `;%PATH%"`;
	

	
	//writeln("Do you wish to commit this to your system? Y or y to proceed ");
    //readf(" %s", c);
    //if ((c == 'Y') || (c == 'y'))
    {
        string newPathVar = joinUpPaths(paths);
        //writeln("newPathVar = ", newPathVar);
			
        // You can set environment variables from Windows Command Prompt using the set or setx command. 
        // The set command only sets the environment variable for the current session. The setx command 
        // sets it permanently, but not for the current session. If you want to set it for current as 
        // well as future sessions, use both setx and set.

        // the echo %PATH% command seems to be a combination of the both System %PATH% and the user %PATH%
        // in that order.  Append (not prepend because of the System paths are first) the new paths 
        // to end of PATH variable. /M for system (machine).  Defaults to current local environment.	

        // setx PATH "%path%;C:\your\path\here\"	
        // set  PATH "%path%;C:\your\path\here\"	
        //  set PATH=C:\myfolder;%PATH%
		// set PATH=%PATH%
        				
        //environment["PATH"] = newPathVar;   // not working
		
        // System PATH is at
        //       Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager\Environment		
        // User PATH is at
        //       Computer\HKEY_USERS\S-1-5-21-3823976785-3597194045-4221507747-1779\Environment		
 
        // The setx command writes variables to the master environment in the registry. Variables set with setx 
        // are only available in future command windows, not in the current command window.
        // will spawnShell be considered not the current command window?
		
        // echo %username%
        // kheaser		
        // How to Find a User's Security Identifier (SID):	
		// wmic useraccount where name="kheaser" get sid
        // SID
        // S-1-5-21-3823976785-3597194045-4221507747-1779
		
        /+
        Pid spawnShell(scope const(char)[] command,
               File stdin = std.stdio.stdin,
               File stdout = std.stdio.stdout,
               File stderr = std.stdio.stderr,
               scope const string[string] env = null,
               Config config = Config.none,
               scope const(char)[] workDir = null,
               scope string shellPath = nativeShell)		
        +/		
		
		File cmdResult;  
	    string cmdLine = `echo %username%`;
		writeln("cmdLine = ", cmdLine);	
		
        auto userName = executeShell("echo %username%");
		
        if (userName.status != 0) writeln("echo %username% failed");
        else writeln("*", userName.output, "*");
		
        writeln("#", strip(userName.output), "#");
        writeln("(", strip(userName.output, "\n", "\t"), ")");
		
        foreach(char ch; userName.output)
        {
            writefln("%2X", ch);   // print out hex values.  Note the non-printable chars			
        }		
        		
		
		writeln("userName.output.length = ", userName.output.length);
		
		string name = strip(userName.output);
        writeln("[", name, "]");		
        string s = `wmic useraccount where name="` ~ name ~ `" get sid`;
        writeln("#", s, "#");			
		

/+		
        foreach(i, ref token; tokens)
        {
            strip(token, " ");
            //writeln("$", token, "$");	
            if (token.length == 0)
            {
                tokens.remove(i);
            }			
        }
+/				
        //writeln("environment variables are inherited from parent process to child process.");
        //writeln("After modifying them, you will have to restart your IDE, or terminal window,"); 
        //writeln("in order for them to udpate.");
    } 		
}     



string runShellCommand(string cmdLine)
{
    auto ret = executeShell(cmdLine);
	
	// Note how first logical expression is negated. It spells out what is being enforced.
    // if ret.status fails (not zero) then throw an exception with the error in 2nd argument
	
    enforce(ret.status == 0, format!"%s failed:\n%s"(cmdLine, ret.output));

    return (ret.output);     
}



string[] queryTerminal(string cmdLine, bool verbose = false)
{
    string cmdOut = runShellCommand(cmdLine);
	
    if (verbose)
    {
        foreach(char ch; cmdOut)
        {
            writef("%2X", ch);    // print out hex values
            if (ch.isPrintable)
                writeln(" ",ch);  // print out only printable chars 
            else
                writeln();        // skip the non-printable chars
        }
    }                       // When no delimiter is provided, strings are split into an array of words,  
    return (cmdOut.split);  // using whitespace as delimiter. Runs of whitespace are merged together 
}                           // (no empty words are produced). 


void decodeChars(string str)
{
    foreach(char ch; str)
    {
        writef("%2X", ch);    // print out hex values
        if (ch.isPrintable)
            writeln(" ",ch);  // print out only printable chars 
        else
        {
            writeln();        // skip the non-printable chars		
            //if ch == 10 new line
            //if ch == 13 			
        }
      
    }   
}

/+ pass in a REG QUERY command +/

string getPathValue(string cmdLine)
{	
    string cmdOut = runShellCommand(cmdLine);    	
	
    auto s = cmdOut.findSplit("REG_SZ");  // The Path value will be contained in s[2]
	
    s[2] = stripLeft(s[2], " ");  // strip out leading spaces between REG_SZ and paths   

    s[2] = s[2].stripRight;       // Strip trailing whitespace (defined by isWhite) tab, vertical 
                                  // tab, form feed, carriage return, and linefeed chars
    return (s[2]);
}



string[] getPaths(string cmdLine)
{	
    string cmdOut = runShellCommand(cmdLine);    	
	
    auto s = cmdOut.findSplit("REG_SZ");  // The Path value will be contained in s[2]
	
    s[2] = stripLeft(s[2], " ");  // strip out leading spaces between REG_SZ and paths   

    s[2] = s[2].stripRight;       // Strip trailing whitespace (defined by isWhite) tab, vertical 
                                  // tab, form feed, carriage return, and linefeed chars
    return (s[2].split(';'));     // Paths are separated by semicolons in Windows    
}




void newFlow()
{	
    /+  
    string usrDomain = runShellCommand(`systeminfo | findstr /B "Domain"`);	
    writeln("usrDomain = ", usrDomain);
	
    string usrName = runShellCommand("echo %username%");
    writeln("usrName = *", usrName, "*");	

    usrName = usrName.stripRight;  // Strip trailing whitespace (defined by isWhite)	
    string usrSID = runShellCommand(`wmic useraccount where name="` ~ usrName ~ `" get sid`);	
    writeln("usrSID = ", usrSID);	

    string[] tokens = usrSID.split;  // string is split into an array of words using whitespace as delimiter
    string domainEnvVars = runShellCommand(`REG QUERY HKEY_USERS\` ~ tokens[1] ~ `\Environment`);	
    writeln("domainEnvVars = ", domainEnvVars);	
    +/

    string currentPath = getPathValue(`REG QUERY HKCU\Environment /v NOVA`);
	writeln("currentPath = ", currentPath);

    /+	
	string lineIn;
    writeln("Enter a path: ");  
	readf(" %s\n", &lineIn);    // ← \n at the end
    writeln("lineIn = ", lineIn);	
    +/
	
    string envValue;
	
	//envValue = currentPath ~ ';' ~ lineIn;
    //string heaser = runShellCommand(`REG ADD HKCU\Environment /f  /v NOVA  /t REG_SZ  /d "` ~ envValue ~ `"`);		
    //writeln("heaser = ", heaser);

	
    string queryStr = runShellCommand(`REG QUERY HKCU\Environment /v Path`);
    //writeln("queryStr = ", queryStr);	
	
    string[] response = queryTerminal(`REG QUERY HKCU\Environment /v NOVA`);	
    //writeln("AAA response = ", response);
	
 
    string timeStr = runShellCommand(`time /t`);
    //writeln("timeStr = ", timeStr);	
	


    envValue = envValue ~ ';' ~ timeStr;
	//writeln("envValue = ", envValue);

	
    response = getPaths(`REG QUERY HKCU\Environment /v NOVA`);	
	foreach( resp; response)
	{
        writeln("resp = ", resp);		
	}
	
    string[] paths = getPaths(`REG QUERY HKCU\Environment /v Path`);
	foreach( path; paths)
	{
        writeln("path = *", path, "*");		
	}
	
	
	// /v = queries for a specific registry key value
    // REG QUERY HKEY_CURRENT_USER\Environment /v PATH
	// REG QUERY HKCU\Environment /v PATH     (just an abbreviated version of HKEY_CURRENT_USER)	
	// REG QUERY HKEY_USERS\S-1-5-21-3823976785-3597194045-4221507747-1779\Environment /v PATH
    	
	// REG ADD HKCU\Environment  /v NOVA  /t REG_SZ  /d this\is\a\new\path
	// Added NOVA above and saw it added to HKEY_USERS\S-1-5-21-3823976785-3597194045-4221507747-1779\Environment as well.
    // REG QUERY HKCU\Environment /v NOVA
    //    HKEY_CURRENT_USER\Environment
    //       NOVA    REG_SZ    this\is\a\new\path	
	//
    // REG ADD HKCU\Environment  /v BACKUPNOVA  /t REG_SZ  /d this\will\be\overwritten /f
    // REG COPY HKCU\Environment  HKCU\Environment\backup
	// The copy works but only for registry folders.  Can't copy individual variables
    // 	
	// REG 

}



void main(char[][] args)
{
    // Assigns the given value to the environment variable with the given name. If 
    // value is null the variable is removed from environment.

    // If the variable does not exist, it will be created. If it already exists, it will be overwritten.
    // environment["foo"] = "bar";

/+
    string envPath = environment["PATH"];  // get the environment variable PATH.  envPath = path;path\here;path\there

    writeln("The raw envPath is this number of character long: ", envPath.length);

    string[] paths = envPath.splitUpPaths();  // paths = ["path", "path\to\here", "path\there"]
+/	

    //environment["NEWPATH"] = envPath;
	
    //envPath = envPath ~ `;C:\path\to\nothing`;
	
    //environment["NEWPATH"] = envPath;

    //writeln("NEWPATH = ", environment["NEWPATH"]);		


    newFlow();

/+  
	char userIn = void;
    writeln("Enter L = List paths or D = Delete path, or A = Add path or Q = Quit");  
	
	int ret = scanf(" %c", &userIn);
	//writeln("ret = ", ret);
    //writeln("userStr = ", userIn);  
		
    while((userIn != 'Q') && (userIn != 'q'))
    {	
        if ((userIn == 'L') || (userIn == 'l'))
        {
		    listPaths(paths);
        }
        else if ((userIn == 'D') || (userIn == 'd'))
        {
		    deletePath(paths);
			listPaths(paths);
        }
        else if ((userIn == 'A') || (userIn == 'a'))
        {
		    addPath(paths);
			listPaths(paths);
        }		
        else
        {
		    writeln("Invalid entry, try again.");
        }		
		
        writeln("Enter L = List paths or D = Delete path, or A = Add path or Q = Quit");   
        readf(" %c", userIn);				
    }

+/	



	
}