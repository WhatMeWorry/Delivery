module texturefuncs;

import derelict.opengl3.gl3;  // defines GLuint
import std.stdio;             //  : writeln, writefln;
import std.string;            // : toStringz; 
import derelict.freetype.ft;  // defines FT_Face
import derelict.freeimage.freeimage; // 
import mytoolbox;



void loadTextureKCH_Unique(ref GLuint texture, string fileName)
{
    glGenTextures(1, &texture);

    writeln("Created Texture with ID: ", texture);
    glBindTexture(GL_TEXTURE_2D, texture); // All future GL_TEXTURE_2D operations will effect our texture object

    // Set our texture parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// Set texture wrapping to GL_REPEAT
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    // Set texture filtering
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // Load, create texture and generate mipmaps
    int width, height;

    //string fileName = "container.jpg";

    // Determine the format of the image.
    // Note: The second paramter ('size') is currently unused, and we should use 0 for it.
    FREE_IMAGE_FORMAT formatFromFile = FreeImage_GetFileType(toStringz(fileName) , 0);
    writeln("formatFromFile is ", formatFromFile);
    FREE_IMAGE_FORMAT formatFromFileName = FreeImage_GetFIFFromFilename(toStringz(fileName));
    writeln("formatFromFileName is ", formatFromFileName);

    if (formatFromFile != formatFromFileName)
    writeAndPause("format from file contents does not match file name format");

    if (FreeImage_FIFSupportsReading(formatFromFile))
    writeln("File format can be read");
    else
    writeln("File format CANNOT be read");

    // We have a known image format, so load it into a bitap
    FIBITMAP* bitmapImage = FreeImage_Load(formatFromFile, toStringz(fileName));

    // Some textures apperar ﬂipped upside-down. This happens because OpenGL expects the 0.0 coordinate on the 
    // y-axis to be on the bottom side of the image, but image susually have 0.0 at the top of the y-axis.

    FreeImage_FlipVertical(bitmapImage);

    // How many bits-per-pixel is the source image?
    int bitsPerPixel = FreeImage_GetBPP(bitmapImage);

    writeln("bitsPerPixel = ", bitsPerPixel);

    GLint  	internalFormat;
    GLint   dataFormat;

    FIBITMAP* bitmap;
    if (bitsPerPixel == 32)
    {
        internalFormat = GL_RGBA;
        dataFormat = GL_BGRA;
        writeln("Source image has ", bitsPerPixel, " bits per pixel.");
        //writeAndPause("SHOULD HAVE 24 BIT IMAGE");
        bitmap = bitmapImage;
    }
    else
    {
        internalFormat = GL_RGB;
        //dataFormat = GL_BGR;
        dataFormat = GL_RGB;
        bitmap = bitmapImage;        
        writeln("Source image has ", bitsPerPixel, " bits per pixel");
        //bitmap = FreeImage_ConvertTo32Bits(bitmapImage);
    }

    // Some basic image info - strip it out if you don't care
    width  = FreeImage_GetWidth(bitmap);
    height = FreeImage_GetHeight(bitmap);
    writeln("Image: ", fileName, " is size: ", width, "x", height, ".");

    // Get a pointer to the texture data as an array of unsigned bytes.
    // Note: At this point bitmap holds either a 32-bit color version of our image - so we get our data from that.
    // Also, we don't need to delete or delete[] this textureData because it's not on the heap (so attempting to do
    // so will cause a crash) - just let it go out of scope and the memory will be returned to the stack.
    GLubyte* textureData = FreeImage_GetBits(bitmap);

    // GetBits Returns a pointer to the data-bits of the bitmap. It is up to you to interpret these bytes
    // correctly, according to the results of FreeImage_GetBPP, FreeImage_GetRedMask,
    // FreeImage_GetGreenMask and FreeImage_GetBlueMask.

    // Construct the texture.
    // Note: The 'Data format' is the format of the image data as provided by the image library. FreeImage decodes images into
    // BGR/BGRA format, but we want to work with it in the more common RGBA format, so we specify the 'Internal format' as such.
    glTexImage2D(GL_TEXTURE_2D,    // Type of texture
                 0,                // Mipmap level (0 being the top level i.e. full size) 
                 internalFormat,   // Internal format
                 width,            // Width of the texture
                 height,           // Height of the texture,
                 0,                // Border in pixels
                 dataFormat,       // Data format
                 GL_UNSIGNED_BYTE, // Type of texture data
                 textureData);     // The image data to use for this texture

    //writeAndPause("Let's take a break");

    // std.string.toStringz (when using string variables) to add the null and return a char*.
    // To convert from char* (from a C function return value) to a D string use std.conv.to!(string).

    glGenerateMipmap(GL_TEXTURE_2D);

    FreeImage_Unload(bitmapImage); 

    glBindTexture(GL_TEXTURE_2D, 0); // Unbind texture when done, so we won't accidentily mess up our texture.

}





void loadTexture(ref GLuint texture, string fileName)
{
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture); // All future GL_TEXTURE_2D operations will effect our texture object

    // Set our texture parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// Set texture wrapping to GL_REPEAT
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    // Set texture filtering
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);


    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST_MIPMAP_NEAREST);    

    // Load, create texture and generate mipmaps
    int width, height;

    //string fileName = "container.jpg";

    // Determine the format of the image.
    // Note: The second paramter ('size') is currently unused, and we should use 0 for it.
    FREE_IMAGE_FORMAT formatFromFile = FreeImage_GetFileType(toStringz(fileName) , 0);
    writeln("formatFromFile is ", formatFromFile);
    FREE_IMAGE_FORMAT formatFromFileName = FreeImage_GetFIFFromFilename(toStringz(fileName));
    writeln("formatFromFileName is ", formatFromFileName);

    if (formatFromFile != formatFromFileName)
        writeAndPause("format from file contents does not match file name format");

    if (FreeImage_FIFSupportsReading(formatFromFile))
        writeln("File format can be read");
    else
        writeln("File format CANNOT be read");

    // We have a known image format, so load it into a bitap

    FIBITMAP* bitmapImage = FreeImage_Load(formatFromFile, toStringz(fileName));

    // Some textures apperar ﬂipped upside-down. This happens because OpenGL expects the 0.0 coordinate on the 
    // y-axis to be on the bottom side of the image, but image susually have 0.0 at the top of the y-axis.

    FreeImage_FlipVertical(bitmapImage);

    // How many bits-per-pixel is the source image?
    int bitsPerPixel = FreeImage_GetBPP(bitmapImage);

    writeln("bitsPerPixel = ", bitsPerPixel);

    GLint  	internalFormat;
    GLint   dataFormat;

    FIBITMAP* bitmap;
    if (bitsPerPixel == 32)
    {
        internalFormat = GL_RGBA;
        dataFormat = GL_BGRA;
        writeln("Source image has ", bitsPerPixel, " bits per pixel. Skipping conversion.");
        //writeAndPause("SHOULD HAVE 24 BIT IMAGE");
		writeln("SHOULD HAVE 24 BIT IMAGE");
        bitmap = bitmapImage;
    }
    else
    {
        internalFormat = GL_RGB;
        //dataFormat = GL_BGR;
        dataFormat = GL_RGB;
        bitmap = bitmapImage;        
        writeln("Source image has ", bitsPerPixel, " bits per pixel");
        //bitmap = FreeImage_ConvertTo32Bits(bitmapImage);
    }

    // Some basic image info - strip it out if you don't care
    width  = FreeImage_GetWidth(bitmap);
    height = FreeImage_GetHeight(bitmap);
    writeln("Image: ", fileName, " is size: ", width, "x", height, ".");



    // Get a pointer to the texture data as an array of unsigned bytes.
    // Note: At this point bitmap holds either a 32-bit color version of our image - so we get our data from that.
    // Also, we don't need to delete or delete[] this textureData because it's not on the heap (so attempting to do
    // so will cause a crash) - just let it go out of scope and the memory will be returned to the stack.
    GLubyte* textureData = FreeImage_GetBits(bitmap);



    // GetBits Returns a pointer to the data-bits of the bitmap. It is up to you to interpret these bytes
    // correctly, according to the results of FreeImage_GetBPP, FreeImage_GetRedMask,
    // FreeImage_GetGreenMask and FreeImage_GetBlueMask.

    // Construct the texture.
    // Note: The 'Data format' is the format of the image data as provided by the image library. FreeImage decodes images into
    // BGR/BGRA format, but we want to work with it in the more common RGBA format, so we specify the 'Internal format' as such.
    glTexImage2D(GL_TEXTURE_2D,    // Type of texture
                 0,                // Mipmap level (0 being the top level i.e. full size) 
                 internalFormat,   // Internal format
                 width,            // Width of the texture
                 height,           // Height of the texture,
                 0,                // Border in pixels
                 dataFormat,       // Data format
                 GL_UNSIGNED_BYTE, // Type of texture data
                 textureData);     // The image data to use for this texture

    // writeAndPause("Let's take a break");

    // std.string.toStringz (when using string variables) to add the null and return a char*.
    // To convert from char* (from a C function return value) to a D string use std.conv.to!(string).

    glGenerateMipmap(GL_TEXTURE_2D);

    FreeImage_Unload(bitmapImage); 

    glBindTexture(GL_TEXTURE_2D, 0); // Unbind texture when done, so we won't accidentily mess up our texture.

}







void loadTextureFromBitmap(ref GLuint texture, ref FT_Face face)
{
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture); // All future GL_TEXTURE_2D operations will effect our texture object

    // Set our texture parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);	// Set texture wrapping to GL_REPEAT
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    // Set texture filtering
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    // Load, create texture and generate mipmaps
    int width, height;

    GLint  	internalFormat;
    GLint   dataFormat;

    writeln("TrueType Glyph Bitmat height is ", face.glyph.bitmap.rows);
    writeln("TrueType Glyph Bitmat width is ", face.glyph.bitmap.width);
    writeln("TrueType Glyph Bitmat pixel_mode is ", face.glyph.bitmap.pixel_mode);

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

    glGenerateMipmap(GL_TEXTURE_2D);

   // FreeImage_Unload(bitmapImage); 

    glBindTexture(GL_TEXTURE_2D, 0); // Unbind texture when done, so we won't accidentily mess up our texture.
}



