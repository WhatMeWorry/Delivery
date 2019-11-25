
module shaders;

//import common;

import bindbc.opengl;    // GLuint
import std.stdio  : writeln;
import std.file   : readText;   // getSize(), readText(), getcwd()
import std.string : toStringz;  // toStringz() 



struct Shader 
{
    GLuint type;
    string file;
    GLuint ID;
}



string readFile(const char[] fileName)
{
    //string currentWorkingDir = getcwd();
    //ulong size = getSize(fileName);

    string contents = readText(fileName);

    return contents;
}


bool compiledStatus(GLuint shaderID)
{
    GLint compiled = 0;
    glGetShaderiv(shaderID, GL_COMPILE_STATUS, &compiled);
    if (!compiled) 
    {
        GLint logLen;
        glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, &logLen);
        char[] msgBuffer = new char[logLen];
        glGetShaderInfoLog(shaderID, logLen, null, &msgBuffer[0]);
        writeln(msgBuffer);
        return false;
    }
    return true;
}


GLuint makeShader(uint shaderType, string source) 
{
    //writeln("makeShader()");
    //writeln("source = ",source);
    immutable char* Cptr = toStringz(source);
    GLuint shaderID = glCreateShader(shaderType);

    glShaderSource(shaderID, 1, &Cptr, null);
    glCompileShader(shaderID);

    writeln("shaderType = ", shaderType);


    // The compilation status will be stored as part of the shader object's state. 
    // This value will be set to GL_TRUE if the shader was compiled without errors 
    // and is ready for use, and GL_FALSE otherwise. It can be queried by calling 
    // glGetShaderiv with arguments shader and GL_COMPILE_STATUS.

    GLint compileStatus;
    glGetShaderiv(shaderID, GL_COMPILE_STATUS, &compileStatus);  //returns GL_TRUE if compile was good
    writeln("compileStatus = ", compileStatus);
    if (compileStatus == GL_TRUE)
        writeln("compile was successful");  
    else
        writeln("compile failed");         
        

    GLint logLen;
    glGetShaderiv(shaderID, GL_INFO_LOG_LENGTH, &logLen);
    writeln("shaders.d logLen = ", logLen);

    GLchar[] vertLog = new GLchar[logLen+1];
    glGetShaderInfoLog(shaderID, logLen, null, vertLog.ptr);
    writeln("Compile result for shader: ", shaderType); 
    if (logLen > 0)
    {
        writeln("vertLog = ", vertLog);
    }

    //writeAndPause(" ");

    if (compiledStatus(shaderID) == false) 
        return -1;

    return shaderID;
}




GLuint createProgramFromShaders(ref Shader[] shaders)
{

    foreach( i, shade; shaders)
    {
        writeln("index = ", i);    
        writeln("struct Shader { GLuint, string, GLuint }");
        writeln("------------------"); 
        writeln("shade = ", shade);
        writeln("------------------"); 

        string sourceCode = readFile(shade.file);
        shaders[i].ID = makeShader(shaders[i].type, sourceCode);
    }

    GLuint programID = glCreateProgram();
    foreach( i, shade; shaders)
    {
        glAttachShader(programID, shaders[i].ID);
    }

    glLinkProgram(programID);

    glUseProgram(programID); 

    return programID;
}
