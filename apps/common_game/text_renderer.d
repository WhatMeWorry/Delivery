module text_renderer;

//import app;

import mytoolbox;

import dynamic_libs.opengl; // : GLubyte, GLchar, GLfloat, GLuint;   // without - Error: undefined identifiers
import dynamic_libs.freetype;

import shader_breakout : ShaderBreakout;
import resource_manager;
import projectionfuncs;

//import common;
//import common_game;
//import derelict.opengl3.gl3;

import std.stdio;
import std.conv;

import gl3n.linalg;               // ivec2


// Holds all state information relevant to a character as loaded using FreeType
struct Character 
{
    GLubyte notused;
    int    dec;      // decimal value
    GLchar itself;    // Associated Key
    GLuint textureID; // ID handle of the glyph texture
    vec2   size;      // Size of glyph
    vec2   bearing;   // Offset from baseline to left/top of glyph
    long   advance;   // Horizontal offset to advance to next glyph
};


class TextRenderer
{
public:
    // Holds a list of pre-compiled Characters
    // std::map<GLchar, Character> Characters; 
    Character[GLchar] characters;

    // Shader used for text rendering
    // Shader TextShader;
    ShaderBreakout textShader;

    GLuint VAO, VBO;

    // TextRenderer(GLuint width, GLuint height);
    this(GLuint width, GLuint height)
    {
        resource_manager.ResMgr.loadShader("source/VertexShaderText.glsl", 
                                           "source/FragmentShaderText.glsl", 
                                           null, "text");
 
        this.textShader = resource_manager.ResMgr.getShader("text");

        //textShader.use();

        glUseProgram(this.textShader.ID);  // equivalent to textShader.use();

        textShader.setInteger("text", 0);

        //mat4 projection = orthographicFunc(0.0, width, height, 0.0, -1.0f, 1.0f);
        mat4 projection = orthographicFunc(0.0, width, 0.0, height, -1.0f, 1.0f);
        //textShader.setMatrix4("projection", projection, COL_MAJOR, true); 
        textShader.setMatrix4("projection", projection, GL_FALSE, true);

        // Configure VAO/VBO for texture quads
        glGenVertexArrays(1, &VAO);
        glGenBuffers(1, &VBO);
        glBindVertexArray(VAO);
        glBindBuffer(GL_ARRAY_BUFFER, VBO);
        glBufferData(GL_ARRAY_BUFFER, GLfloat.sizeof * 6 * 4, null, GL_DYNAMIC_DRAW);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * GLfloat.sizeof, cast(const(void)*) 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);

    }

    

void load(string fontName, /+ref Character[GLchar] characters,+/ int fontSize)
{
    // Then initialize and load the FreeType library
    FT_Library ft;    
    if (FT_Init_FreeType(&ft)) // All functions return a value different than 0 whenever an error occurred
        writeAndPause("Freetype could not init FreeType Library");
    // Load font as face
    FT_Face face;
    if (FT_New_Face(ft, cast(const(char)*) fontName, 0, &face))
        writeln("Freetype failed to load font ", fontName);
    // Set size to load glyphs as
    FT_Set_Pixel_Sizes(face, 0, fontSize);
    // Disable byte-alignment restriction
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1); 
    // Then for the first 128 ASCII characters, pre-load/compile their characters and store them
    foreach (GLubyte c; 0..127)
    {
        // Load each character glyph 
        // use function FT_Load_Char instead of FT_Load_Glyph. It is equivalent
        // to calling FT_Get_Char_Index, then FT_Load_Glyph.
        if (FT_Load_Char(face, c, FT_LOAD_RENDER))    // FT_Load_Char(face, 'Z', FT_LOAD_RENDER)
        {
            writeln("Failed to load Glyph", c); 
            continue;
        } 

        //writeln("Glyph ", c, " ", to!char(c), " Bitmap height x width: ", face.glyph.bitmap.rows, "x", face.glyph.bitmap.width);

        // Generate texture
        GLuint texture;
        glGenTextures(1, &texture);
        glBindTexture(GL_TEXTURE_2D, texture);

        glTexImage2D(
                     GL_TEXTURE_2D,
                     0,
                     GL_RED,
                     face.glyph.bitmap.width,
                     face.glyph.bitmap.rows,
                     0,
                     GL_RED,
                     GL_UNSIGNED_BYTE,
                     face.glyph.bitmap.buffer
                     );

        // Set texture options
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

        // Now store character for later use
        // initialize a structure via the constructor using variable set above.

        int   i = to!int(c);
        char ch = to!char(c);

        Character character = {
            c,
            i,
            ch,
            texture,
            vec2(face.glyph.bitmap.width, face.glyph.bitmap.rows),
            vec2(face.glyph.bitmap_left, face.glyph.bitmap_top),
            face.glyph.advance.x
        };

        //Characters.insert(std::pair<GLchar, Character>(c, character));
        characters[c] = character;
        glBindTexture(GL_TEXTURE_2D, 0); 
    }  
    FT_Done_Face(face);  // Destroy FreeType once we're finished
    FT_Done_FreeType(ft);  // library is in another function... Fix later.
}


// void renderText(ref Character[GLchar] characters, GLuint VAO, GLuint VBO, GLuint progID, 
//                 string text, GLfloat x, GLfloat y, GLfloat scale, vec3 color)
void renderText(string text, GLfloat x, GLfloat y, GLfloat scale, vec3 color = vec3(1.0f))
{
    // Activate corresponding render state

    this.textShader.use();
    this.textShader.setVector3f("textColor", color);
    glActiveTexture(GL_TEXTURE0);
    glBindVertexArray(this.VAO);

    // Iterate through all characters
    foreach(i, c; text)
    {
        Character ch = characters[c];

        //writeln("c = ", c, " ch.texture = ", ch.textureID);

        GLfloat xpos = x + ch.bearing.x * scale;
        GLfloat ypos = y - (ch.size.y - ch.bearing.y) * scale;

        //        ypos = y + (characters['H'].bearing.y - ch.bearing.y) * scale;


        GLfloat w = ch.size.x * scale;
        GLfloat h = ch.size.y * scale;
        // Update VBO for each character

        GLfloat[4][6] vertices =
        [
            [ xpos,     ypos + h,   0.0, 0.0 ],            
            [ xpos,     ypos,       0.0, 1.0 ],
            [ xpos + w, ypos,       1.0, 1.0 ],

            [ xpos,     ypos + h,   0.0, 0.0 ],
            [ xpos + w, ypos,       1.0, 1.0 ],
            [ xpos + w, ypos + h,   1.0, 0.0 ]           
        ];

        // Render glyph texture over quad
        glBindTexture(GL_TEXTURE_2D, ch.textureID);

        // Update content of VBO memory
        glBindBuffer(GL_ARRAY_BUFFER, VBO);

        glBufferSubData(GL_ARRAY_BUFFER, 0, vertices.sizeof, vertices.ptr); // Be sure to use glBufferSubData and not glBufferData

        glBindBuffer(GL_ARRAY_BUFFER, 0);
        // Render quad
        glDrawArrays(GL_TRIANGLES, 0, 6);
        // Now advance cursors for next glyph (note that advance is number of 1/64 pixels)
        x += (ch.advance >> 6) * scale; // Bitshift by 6 to get value in pixels (2^6 = 64 (divide 
                                        // amount of 1/64th pixels by 64 to get amount of pixels))

    }
    glBindVertexArray(0);
    glBindTexture(GL_TEXTURE_2D, 0);
}


};