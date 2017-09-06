module shader_breakout;

import common;

import mytoolbox;

import std.stdio;    // writeln
import std.conv;     // to
import gl3n.linalg;  // vec3 mat4


// General purpsoe shader object. Compiles from file, generates
// compile/link-time error messages and hosts several utility 
// functions for easy management.

class ShaderBreakout
{
public:
    // State
    GLuint ID; 
    string logicalName;

    // Constructor
    this() { }

    // Sets the current shader as active
    ShaderBreakout use()
    {
        //writeln("this.ID = ", this.ID);
        //writeln("is this same as program id");
        glUseProgram(this.ID);
        return this;
    }

    // Compiles the shader from given source code
    void compile(const GLchar *vertexSource, const GLchar *fragmentSource, 
                 const GLchar *geometrySource = null)  // Note: geometry source code is optional 
    {
        GLuint sVertex, sFragment, gShader;
        // Vertex Shader
        sVertex = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(sVertex, 1, &vertexSource, null);
        glCompileShader(sVertex);
        checkCompileErrors(sVertex, "VERTEX");
        // Fragment Shader
        sFragment = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(sFragment, 1, &fragmentSource, null);
        glCompileShader(sFragment);
        checkCompileErrors(sFragment, "FRAGMENT");
        // If geometry shader source code is given, also compile geometry shader
        if (geometrySource != null)
        {
            gShader = glCreateShader(GL_GEOMETRY_SHADER);
            glShaderSource(gShader, 1, &geometrySource, null);
            glCompileShader(gShader);
            checkCompileErrors(gShader, "GEOMETRY");
        }
        // Shader Program
        this.ID = glCreateProgram();
        glAttachShader(this.ID, sVertex);
        glAttachShader(this.ID, sFragment);
        if (geometrySource != null)
            glAttachShader(this.ID, gShader);
        glLinkProgram(this.ID);
        checkCompileErrors(this.ID, "PROGRAM");
        // Delete the shaders as they're linked into our program now and no longer necessery
        glDeleteShader(sVertex);
        glDeleteShader(sFragment);
        if (geometrySource != null)
            glDeleteShader(gShader);
    }

    // Utility functions
    void setFloat(const GLchar *name, GLfloat value, GLboolean useShader = false)
    {
        if (useShader) this.use();
        glUniform1f(glGetUniformLocation(this.ID, name), value);
    }

    void setInteger(const GLchar *name, GLint value, GLboolean useShader = false)
    {
        if (useShader) this.use();
        //writeln("this.ID = ", this.ID);
        //writeln("name = ", to!string(name));
        //writeln("value = ", value);
        //writeln("ONE = glGetUniformLocation(this.ID, name) = ", glGetUniformLocation(this.ID, name), "\n\n\n" );
        glUniform1i(glGetUniformLocation(this.ID, name), value);
    }

    void setVector2f(const GLchar *name, GLfloat x, GLfloat y, GLboolean useShader = false)
    {
        if (useShader) this.use();
        glUniform2f(glGetUniformLocation(this.ID, name), x, y);
    }

    void setVector2f(const GLchar *name, const vec2 value, GLboolean useShader = false)
    {
        if (useShader) this.use();
        glUniform2f(glGetUniformLocation(this.ID, name), value.x, value.y);
    }

    void setVector3f(const GLchar *name, GLfloat x, GLfloat y, GLfloat z, GLboolean useShader = false)
    {
        if (useShader) this.use();
        glUniform3f(glGetUniformLocation(this.ID, name), x, y, z);
    }

    void setVector3f(const GLchar *name, const vec3 value, GLboolean useShader = false)
    {
        if (useShader) this.use();
        //writeln("this.ID = ", this.ID);
        //writeln("name = ", to!string(name));
        //writeln("value = ", value);
        //writeln("TWO = glGetUniformLocation(this.ID, name) = ", glGetUniformLocation(this.ID, name), "\n\n\n" );
        glUniform3f(glGetUniformLocation(this.ID, name), value.x, value.y, value.z);
    }

    void setVector4f(const GLchar *name, GLfloat x, GLfloat y, GLfloat z, GLfloat w, GLboolean useShader = false)
    {
        if (useShader) this.use();
        glUniform4f(glGetUniformLocation(this.ID, name), x, y, z, w);
    }

    void setVector4f(const GLchar *name, const vec4 value, GLboolean useShader = false)
    {
        if (useShader) this.use();
        //writeln("this.ID = ", this.ID);
        //writeln("name = ", to!string(name));
        //writeln("value = ", value);
        //writeln("THREE = glGetUniformLocation(this.ID, name) = ", glGetUniformLocation(this.ID, name), "\n\n\n" );
        glUniform4f(glGetUniformLocation(this.ID, name), value.x, value.y, value.z, value.w);
    }

    void setMatrix4(const GLchar *name, ref const mat4 matrix, GLboolean ROW_MAJOR, GLboolean useShader = false, )
    {
        if (useShader) this.use();
  
        //writeln("this.ID = ", this.ID);
        //writeln("name = ", to!string(name));
        //writeln("value = ", matrix);
        //writeln("FOUR = glGetUniformLocation(this.ID, name) = ", glGetUniformLocation(this.ID, name), "\n\n\n" );

        // glUniformMatrix4fv(glGetUniformLocation(this.ID, name), 1, GL_FALSE, &matrix[0][0]);   // WORKS
        // (2) must be &projection[0][0]  or  cast(const(float)*) projection.ptr
        glUniformMatrix4fv(glGetUniformLocation(this.ID, name), 1, ROW_MAJOR, &matrix[0][0]);       
    }

private:
    // Checks if compilation or linking failed and if so, print the error logs
    void checkCompileErrors(GLuint object, string type)
    {
        GLint success;
        GLchar[1024] infoLog;
        if (type != "PROGRAM")
        {
            glGetShaderiv(object, GL_COMPILE_STATUS, &success);
            if (!success)
            {
                glGetShaderInfoLog(object, 1024, null, infoLog.ptr);
                writeln("Error Shader Compile-time error: Type: ", type, "\n");
            }
        }
        else
        {
            glGetProgramiv(object, GL_LINK_STATUS, &success);
            if (!success)
            {
                glGetProgramInfoLog(object, 1024, null, infoLog.ptr);
                writeln("Error Shader link-time error: Type: ", type, "\n");
            }
        }
    }
};

