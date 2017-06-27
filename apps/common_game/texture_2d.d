module texture_2d;

import derelict.opengl3.gl3;

import std.stdio;


// Texture2D is able to store and configure a texture in OpenGL.
// It also hosts utility functions for easy management.

class Texture2D
{
public:
    // Holds the ID of the texture object, used for all texture operations to reference to this particlar texture
    GLuint ID;
    string friendlyName;
    // texture image dimensions
    GLuint width, height;   // Width and height of loaded image in pixels
    // Texture Format
    GLuint internal_Format; // Format of texture object
    GLuint image_Format;    // Format of loaded image
    // Texture configuration
    GLuint wrap_S;          // Wrapping mode on S axis
    GLuint wrap_T;          // Wrapping mode on T axis
    GLuint filter_Min;      // Filtering mode if texture pixels < screen pixels
    GLuint filter_Max;      // Filtering mode if texture pixels > screen pixels
	

    this()    // Constructor (sets default texture modes)
    {
        width  = 0;
        height = 0;
        internal_Format = GL_RGB;
        image_Format    = GL_RGB;
        wrap_S = GL_REPEAT;
        wrap_T = GL_REPEAT;
        filter_Min = GL_LINEAR; 
        filter_Max = GL_LINEAR;
        ID = 0;
    }

    // Generates texture from image data
    void generate(GLuint width, GLuint height,  /* unsigned */  char* data)  // does D have unsigned char?
    {
        this.width = width;
        this.height = height;
        // Create Texture
		glGenTextures(1, &this.ID);                 // HAD TO ADD THIS MYSELF?
        glBindTexture(GL_TEXTURE_2D, this.ID);
        glTexImage2D(GL_TEXTURE_2D, 0, 
                     this.internal_Format, width, height, 0, 
                     this.image_Format, GL_UNSIGNED_BYTE, data);
        // Set Texture wrap and filter modes
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, this.wrap_S);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, this.wrap_T);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, this.filter_Min);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, this.filter_Max);
        // Unbind texture
        glBindTexture(GL_TEXTURE_2D, 0);
    }

    // Binds the texture as the current active GL_TEXTURE_2D texture object
    void bind() const
    {
        //writeln("Binding to texture ID = ", this.ID);
        glBindTexture(GL_TEXTURE_2D, this.ID);
    }
};


