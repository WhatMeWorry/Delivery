module resource_manager;

import common;
import common_game;

import std.stdio;
import mytoolbox;

// In Visual Studio 2010, the text cursor has changed from the blinking line, 
// to a blinking grey box around the characters. When I type overwrites the text 
// in front of it.  I'm not sure how to get this off? 
// If pressing the Insert key doesn't work, try doubleclicking the INS/OVR label in the 
// lower right corner of Visual Studio.

// int[13] straightJacket;     // fixed size
// int[]   accordion;          // size can grow or shrink

	
// A static singleton ResourceManager class that hosts several functions to load Textures
// and Shaders. Each loaded texture and/or shader is also stored for future reference by
// string handles. All functions and resources are static and no public constructor is defined.


class ResMgr
{
public:

    static Texture2D[string]      aaTextures;   // static associative array or 2d textures.  It has a user defined name.
    static ShaderBreakout[string] aaShaders;    // static associative array of shaders. It has a user defined name.

    static ShaderBreakout loadShader(string vertShader, string fragShader, string geoShader, string name)
    {
        aaShaders[name] = new ShaderBreakout;

        Shader[] shaders =
        [
            Shader(GL_VERTEX_SHADER,   vertShader, 0),
         // Shader(GL_GEOMETRY_SHADER, geoShader,  0),
            Shader(GL_FRAGMENT_SHADER, fragShader, 0)
        ];		
		
        GLuint programID = createProgramFromShaders(shaders);
       
        aaShaders[name].ID = programID;
        aaShaders[name].logicalName = name;

        return aaShaders[name];
    }

    static ShaderBreakout getShader(string name)
    {
        if (name !in aaShaders)
        {
            writeln("Invalid SHADER named: ", name, " is NOT in associative array of shaders");
            writeAndPause("Resolve this issue before continuing...");
        }
				
        return aaShaders[name];
    }
	

    static Texture2D getTexture(string name)
    {
        if (name !in aaTextures)
        {
            writeln("Invalid TEXTURE named: ", name, " is NOT in associative array of shaders");
            writeAndPause("Resolve this issue before continuing...");
        }
					
	
        return aaTextures[name];
    }

	
    void Clear()
    {
        // delete all shaders and textures	
        foreach(shader; aaShaders)
            glDeleteProgram(shader.ID);
        foreach(texture; aaTextures)
            glDeleteTextures(1, &texture.ID);
    }


}