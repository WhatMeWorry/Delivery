module freetypefuncs;

import derelict.freetype.ft;  // defines FT_Face
import std.stdio;
import std.string;   // format()
import std.conv; //   : to;
import std.traits;
import std.typetuple;
import derelict.opengl3.gl3;  // defines GLubyte, GLchar, GLuint, GLfloat etc.
import gl3n.linalg;           // vec3

import common;

import mytoolbox;


// Holds all state information relevant to a character as loaded using FreeType
struct Glyph 
{
    GLubyte notused;
    int    dec;      // decimal value
    GLchar itself;    // Associated Key
    GLuint textureID; // ID handle of the glyph texture
    vec2   size;      // Size of glyph
    vec2   bearing;   // Offset from baseline to left/top of glyph
    long   advance;   // Horizontal offset to advance to next glyph
};


struct TextRenderingSystem
{
    Glyph[GLchar] font;
 
    static GLuint progID;
    static GLuint VAO;
    static GLuint VBO;
} 

/+
Glyph[GLchar] courierBold;
Glyph[GLchar] phoenixRising;
Glyph[GLchar] eagleLake;
GLuint VAO, VBO;
+/


/+
https://gitlab.com/wikibooks-opengl/modern-tutorials/blob/master/text02_atlas/text.cpp

http://freetype.sourceforge.net/freetype2/docs/tutorial/step1.html

A face object models all information that globally describes the face. Usually, this data can be accessed 
directly by dereferencing a handle, like in face−>num_glyphs.

The complete list of available fields in in the FT_FaceRec structure description. However, we describe here 
a few of them in more details:

num_glyphs
This variable gives the number of glyphs available in the font face. A glyph is simply a character image. 
It doesn't necessarily correspond to a character code though.

face_flags
A 32-bit integer containing bit flags used to describe some face properties. For example, the flag 
FT_FACE_FLAG_SCALABLE is used to indicate that the face's font format is scalable and that glyph images 
can be rendered for all character pixel sizes. For more information on face flags, please read the 
FreeType 2 API Reference.

units_per_EM
This field is only valid for scalable formats (it is set to 0 otherwise). It indicates the number of font 
units covered by the EM.

num_fixed_sizes
This field gives the number of embedded bitmap strikes in the current face. A strike is simply a series 
of glyph images for a given character pixel size. For example, a font face could include strikes for 
pixel sizes 10, 12 and 14. Note that even scalable font formats can have embedded bitmap strikes!

available_sizes
A pointer to an array of FT_Bitmap_Size elements. Each FT_Bitmap_Size indicates the horizontal and 
vertical character pixel sizes for each of the strikes that are present in the face.


+/
void displayFaceInfo(FT_Face face)
{
    breakdown_FT_Face_2_Ways();

    string s = std.conv.to!string(face.family_name);
    writeln("family name is ", s);
    s = std.conv.to!string(face.style_name);
    writeln("style name is ", s);

    // A glyph is a character image, nothing more – it thus doesn't necessarily 
    // correspond to a character code.

    //writeln("face.num_glyphs = ", face.num_glyphs);
    //writeln("face.face_flags = ", face.face_flags);
    //writeln("face.units_per_EM = ", face.units_per_EM);
    //writeln("face.num_fixed_sizes = ", face.num_fixed_sizes);
    //writeln("face.available_sizes = ", face.available_sizes);
    //writeln("");
    //writeln("face.size.metrics.x pixels per EM = ", face.size.metrics.x_ppem);
    //writeln("face.size.metrics.y pixels per EM = ", face.size.metrics.y_ppem);
    //writeln("face.size.metrics.x scale ", face.size.metrics.x_scale);
    //writeln("face.size.metrics.y scale ", face.size.metrics.y_scale);
    //writeln("face.num_charmaps = ", face.num_charmaps);

    //writeln("Bitmap Width in pixels = ", face.glyph.bitmap.width);
    //writeln("Bitmap Height in pixels = ", face.glyph.bitmap.rows);
}


void breakdown_FT_Face_2_Ways(/+FT_Face face+/)
{

    // FT_Face  face;  below fails because this is a C structure and not a D struc.
    
    struct S
    {
        int i;
        float f;
    }
    S face;

    foreach (index, name; FieldNameTuple!/+FT_Face+/S)             // works only for fields
        writefln("%s: %s", name, face.tupleof[index]);

    foreach (name; FieldNameTuple!/+FT_Face+/S)                   // works for methods, opDispatch and similar
        writefln("%s: %s", name, mixin("face." ~ name));    

}








void initializeFreeTypeLibrary(ref FT_Library lib)
{
    if (FT_Init_FreeType(&lib))
    {
        writeAndPause("Could not initialize FreeType Library");
    }
    int v0,v1,v2;
    FT_Library_Version(lib, &v0, &v1, &v2);
    writeln("FreeType version = ", v0, ".", v1, ".", v2);   
}

void initializeFreeTypeFace(ref FT_Face face, FT_Library library, const(char)* font)
{
    // assume FreeType and library has been loaded and initialized

    //int error = FT_New_Face(library, "../fonts/courbd.ttf", 0, &face);
    int error = FT_New_Face(library, font, 0, &face);
    writeln("error = ", error);

    if (error == FT_Err_Unknown_File_Format)
        writeAndPause("Unknown file format");        


}


void initializeFreeTypeAndFace(ref FT_Face face)
{
    DerelictFT.load();  // Load the FreeType library - Now FreeType functions can be called

    //writeAndPause("after DerelictFT.load");

    FT_Library library;   // FT_Init_FreeType(&freeType);
    int v0,v1,v2;

    if (FT_Init_FreeType(&library))
    {
        writeAndPause("Could not initialize FreeType Library");
    }

    FT_Library_Version(library, &v0, &v1, &v2);
    writeln("FreeType version = ", v0, ".", v1, ".", v2);

    int error = FT_New_Face(library, "../fonts/courbd.ttf", 0, &face);
    writeln("error = ", error);

    if (error == FT_Err_Unknown_File_Format)
        writeAndPause("Unknown file format");        

    //writeAndPause("after FT_New_Face");
}




void initializeCharacters(ref FT_Face face, ref Glyph[GLchar] glyphs, int size = 24)
{

    //displayFaceInfo(face);

    // Set size to load glyphs as
    FT_Set_Pixel_Sizes(face, 
                       0,      // pixel_width 0 means width is same as pixel height
                       size);  // pixel_height

    //displayFaceInfo(face);

    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);    // Disable byte-alignment restriction

    foreach (GLubyte c; 32..127)
    {
        // Load each character glyph 
        // use function FT_Load_Char instead of FT_Load_Glyph. It is equivalent
        // to calling FT_Get_Char_Index, then FT_Load_Glyph.

        if (FT_Load_Char(face, c, FT_LOAD_RENDER))    // FT_Load_Char(face, 'Z', FT_LOAD_RENDER)
        {
            writeln("Failed to load Glyph", c);         
        }  
        char ch = to!char(c);
        int i = to!int(c);

        //writeln("Glyph ", ch, " Bitmap height x width: ", face.glyph.bitmap.rows, "x", face.glyph.bitmap.width);

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
        Glyph glyph = {
            c,
            i,
            ch,
            texture,
            vec2(face.glyph.bitmap.width, face.glyph.bitmap.rows),
            vec2(face.glyph.bitmap_left, face.glyph.bitmap_top),
            face.glyph.advance.x
        };

        //Characters.insert(std::pair<GLchar, Character>(c, character));
        glyphs[c] = glyph;
        glBindTexture(GL_TEXTURE_2D, 0); 
    }  


    //FT_Done_Face(face);  // Destroy FreeType once we're finished
    //FT_Done_FreeType(library);  // library is in another function... Fix later.
}



void renderText(ref Glyph[GLchar] characters, GLuint VAO, GLuint VBO, GLuint progID, 
                string text, GLfloat x, GLfloat y, GLfloat scale, vec3 color)
{
    // Activate corresponding render state
    glUseProgram(progID);
    glUniform3f(glGetUniformLocation(progID, "textColor"), color.x, color.y, color.z);
    glActiveTexture(GL_TEXTURE0);
    glBindVertexArray(VAO);

    // Iterate through all characters
    foreach(i, c; text)
    {
        Glyph ch = characters[c];

        GLfloat xpos = x + ch.bearing.x * scale;
        GLfloat ypos = y - (ch.size.y - ch.bearing.y) * scale;

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


void initTextRenderingSystem(ref TextRenderingSystem textRenderSys)
{
    Shader[] shaders =
    [
        Shader(GL_VERTEX_SHADER,   "source/VertexShaderText.glsl",   0),
        Shader(GL_FRAGMENT_SHADER, "source/FragmentShaderText.glsl", 0)
    ];
    textRenderSys.progID = createProgramFromShaders(shaders);

    glUseProgram(textRenderSys.progID);

    mat4 projection = orthographicFunc(0.0, 800 /+width+/, 0.0, 600 /+height+/, -1.0, 1.0);
    glUniformMatrix4fv(glGetUniformLocation(textRenderSys.progID, "projection"), 1, GL_FALSE, &projection[0][0]); //WORKS

    FT_Library library; 
    FT_Face courierBoldFont;   // Load font as face

    initializeFreeTypeAndFace(library, courierBoldFont,   "../fonts/ocraext.ttf");

    initializeCharacters(courierBoldFont, textRenderSys.font);


    // Configure VAO/VBO for texture quads
    glGenVertexArrays(1, &textRenderSys.VAO);
    glGenBuffers(1, &textRenderSys.VBO);
    glBindVertexArray(textRenderSys.VAO);
    glBindBuffer(GL_ARRAY_BUFFER, textRenderSys.VBO);
    glBufferData(GL_ARRAY_BUFFER, GLfloat.sizeof * 6 * 4, null, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * GLfloat.sizeof, cast(const(void)*) 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
}





/+  // INTERESTING CODE 

    // For a simple value structure we will use the following definitions
    // struct Name
    // {
    //     type1  Name1  Value1;
    //     type2  Name2  Value2;
    //       o      o      o
    //     typeN  NameN  ValueN;
    // }

    struct Meta 
    {
        string type;
        string name;
        string value;
    }

    Meta[50] members;

    string[50] types;
    string[50] names;
    string[50] values;

    auto allNames = FieldNameTuple!(FT_FaceRec);  
    writeln(allNames);
    foreach (i, name; allNames)
    {
        names[i] = name;
    }

    auto allTypesAndVals = face.tupleof;
    writeln(allTypesAndVals);
    foreach (j, member; allTypesAndVals)
    { 
        types[j] = typeof(member).stringof; 
        values[j] = format("%s",member); 
    } 

    writeln("  Types      Names       Values");
    foreach (k, member; allTypesAndVals)
    {   
        writeln(types[k],"     ", names[k], "     ", values[k]);
    }
+/


void initializeFreeTypeAndFace(ref FT_Library library, ref FT_Face face, const(char)* font)
{
    DerelictFT.load();  // Load the FreeType library - Now FreeType functions can be called

    //writeAndPause("after DerelictFT.load");

    //FT_Library library;   // FT_Init_FreeType(&freeType);
    int v0,v1,v2;

    if (FT_Init_FreeType(&library))  // 0 means success
    {
        writeAndPause("Could not initialize FreeType Library");
    }

    FT_Library_Version(library, &v0, &v1, &v2);
    writeln("FreeType version = ", v0, ".", v1, ".", v2);

    //writeAndPause("Check FreeType version just displayed");

    // A face describes a given typeface and style. For example, ‘Times New Roman Regular’ 
    // and ‘Times New Roman Italic’ correspond to two different faces.

    int error = FT_New_Face(library, font, 0, &face);  // 0 means success
    if (error)
    {
        writeAndPause("FT_New_Face failed loading font");       
    }

    if (error == FT_Err_Unknown_File_Format)
        writeAndPause("Unknown file format");        

    writeln("FT_New_Face succeeded");

}
