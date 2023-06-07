
module openglAbstractionLayers;

import dynamic_libs.opengl;  // GLuint, all the glXXXXX commands
import mytoolbox;     // without - Error: no property bytes for type float[]
                      // writeAndPause()  .bytes  .elements
					  
import std.stdio;
					  
// Compatibillty and Core Profiles

/+ 
Since the original publication of the OpenGL specification in 1992,
opengl has accumulated a lot of fixed functionality which is considered
obsolete. Modern opengl should use the programmable pipeline. Versioni 3.0
introduced a concept of Compatibillty and Core Profiles

Compatibility Profile
    All OpenGL APIs (Fixed and Programmable pipeline)

Core Profile
    Modern OpenGL APIs (Programmable pipeline. No deprecetated features)

-----------------------------------------------------------------------------------------

Vertex Array Objects

Especially useful when loading complete models from files.

In OpenGL 3.3 and later if you use core contexts, you don't even have a choice in the matter; you 
have to use them because OpenGL in those versions don't have a default VAO anymore.

Vertex Buffer
    Vertex 1
    Vertex 2
     o
     o
    Vertex N
   
encapsulate all the objects that are involved in getting vertices into the GPU in a single object.
When you think about it, getting all the vertices into the GPU and having the GPU correctly parse
the vertx buffer involves quite a lot of objects and changes to the OpenGL state.

Vertex Specification
    Vertex Buffer 1
    Vertex Buffer 2
     o
     o
    Vertex Buffer N
	
So far we have used a single vertex buffer but in the future we will see how to use multiple vertex 
buffer simultaneously.

We may also have an option index buffer. We also need to define the buffer layout using glVertexAttribPointer.
And finally we need to enable the vertex attributes that we plan to use by calling glEnableVertexArribArray.


                 Buffer                                 Enable Attr 0 (Position)
                                                        Enable Attr 1 (Color)
        Vertex #1         |      Vertex #2
    position     color    | position     color
  | X | Y | Z | R | G | B | X | Y | Z | R | G | B | 
   offset      offset      offset      offset
   0           12          24          36
   
Now let's image we have a full blown game with lots of meshes and using different shader programs.

The VAO is basically a thin meta object. It doesn't hold a lot of data on its own like the vertex
buffers. Instead it simply contains pointers to all the buffers that belong to it. In addition, the
VAO stores the layout and the list of enabled attributes. So whenever you bind a VAO, OpenGL automatically
binds all of its buffers.


    Vertex Buffer 1 <---------+
    Vertex Buffer 2 <--------VAO-------> Enable Attr 0 (Position)
     o                        |          Enable Attr 1 (Color)
     o                        |
    Vertex Buffer N <---------+           
   
If you have multiple meshes in you game, you can simply assign a VAO per mesh and in order
to switch between meshes you just need to bind the cooresponding VAO.

// Original C++ code - Keep for reference

void CreateCubeVAO()
{
    glGenVertexArrays(1, &CubeVAO); // *
    glBindVertexArray(CubeVAO); 

    // * Note that there is no target here as with buffers or textures. The
    // target is simply embedded in the name of the function (Vertex Array - Oject)
    // From now on everything that we do in this function will be recorded in this VAO.

    Vertex Vertices[8];

    Vector2f t00 = Vector2f(0.0f, 0.0f);  // Bottom left
    Vector2f t01 = Vector2f(0.0f, 1.0f);  // Top left
    Vector2f t10 = Vector2f(1.0f, 0.0f);  // Bottom right
    Vector2f t11 = Vector2f(1.0f, 1.0f);  // Top right

    Vertices[0] = Vertex(Vector3f(0.5f, 0.5f, 0.5f), t00);
    Vertices[1] = Vertex(Vector3f(-0.5f, 0.5f, -0.5f), t01);
    Vertices[2] = Vertex(Vector3f(-0.5f, 0.5f, 0.5f), t10);
    Vertices[3] = Vertex(Vector3f(0.5f, -0.5f, -0.5f), t11);
    Vertices[4] = Vertex(Vector3f(-0.5f, -0.5f, -0.5f), t00);
    Vertices[5] = Vertex(Vector3f(0.5f, 0.5f, -0.5f), t10);
    Vertices[6] = Vertex(Vector3f(0.5f, -0.5f, 0.5f), t01);
    Vertices[7] = Vertex(Vector3f(-0.5f, -0.5f, 0.5f), t11);

    glGenBuffers(1, &CubeVBO);               // generate the vertex buffer
    glBindBuffer(GL_ARRAY_BUFFER, CubeVBO);  // bind the vertex buffer (or in other words, make it active)
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);  // upload (to GPU) the vertices

    // enable the two vertex attributes and configure the layout for each attribute
    // Critical: must place calls to glVertexAttribPointer after glBindBuffer because
    // the currently bound buffer to GL_ARRAY_BUFFER and the vertex attribute info is
    // recorded in the VAO.
	
    // position
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);

    // tex coords
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)(3 * sizeof(float)));

    unsigned int Indices[] = {0, 1, 2, 1, 3, 4, 5, 6, 3, 7, 3, 6, 2, 4, 7, 0, 7, 6,
                              0, 5, 1, 1, 5, 3, 5, 0, 6, 7, 4, 3, 2, 1, 4, 0, 2, 7 };

    glGenBuffers(1, &CubeIBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, CubeIBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);

    // Why does the CubeIBO not need glEnableVertexAttribArray and glVertexAttribPointer calls?

    // We are done with all the working objects. The info has been transferred to the GPU and
    // state is saved off with the VAO.  Unbinding prevents potential other parts of our code
    // from corrupting out VAO.

    glBindVertexArray(0);                // zero means to unbind the current vertex array (object)
    glDisableVertexAttribArray(0);       // disable all the enabled vertex attributes
    glDisableVertexAttribArray(1);
    glBindBuffer(GL_ARRAY_BUFFER, 0);    // unbind the current array buffer and index buffer
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

+/



      
// Rendering can take place as non-indexed rendering or indexed rendering. 
// All non-indexed drawing commands are of the form, gl*Draw*Arrays*, where the * values can 
// be filled in with different words. All indexed drawing commands are of the form, gl*Draw*Elements*

void renderHexBoard(float[] vertices, GLuint VAO)
{
    glBindVertexArray(VAO);  // if commented out, the following glDrawArrays don't work. Blank Screen!

    /+
    writeln("vertices = ", vertices);
	
    writeln("vertices.length = ", vertices.length);
    writeln("vertices.elements = ", vertices.elements);	
    writeln("vertices.bytes = ", vertices.bytes);	
    writeln("vertices.length/6 = ", vertices.length/6);	
	+/
	
	/+
    have a 3x3 hexboard or 9 hexes total. 9 hex with 6 points apiece is 9*6 = 54 points.
	each point has an xyz component or 54 * 3 = 162.  But the entire array shows 324 elements?
    Remember the color component that is interleaved. So the color or rgb * 3 = 162 accounts for
	the other 162 elements. Remember, the array looks like:
    
    xyzRGBxyzRGBxyzRGBxyzRGBxyzRGBxyzRGBxyzRGBxyzRGBxyzRGBxyzRGB...xyzRGB
    1                                                                   324
    
    the the i in glDrawArrays below ranges from 0,6,12,...,312,318  
	
    So the glDrawArrays is doing BOTH THE POSITION AND COLOR COMPONENTS.
	
    vertices.length = 324
    vertices.elements = 324
    vertices.bytes = 1296
    vertices.length/6 = 54
    +/	

    // If the vao/vbo consisted of just a simple primative(say triangle for example)
    // we could just get by with:
    // glBindVertexArray(VAO);	
    // glDrawArrays(GL_TRIANGLES, 0, 3);
    // but in out case we are doing an entire hex board so we need the vertices array
    // and while loop present.

    // glDrawArrays will draw from the currently bound vertex attribute arrays, which are "created" and 
    // bound themselves with glVertexAttribPointer and glEnableVertexAttribArray, which do use the 
    // currently bound vertex buffer. It doesn't matter if the vertex attributes are all from one buffer 
    // or multiple buffers, and you don't need any particular vertex buffer to be bound when drawing; all 
    // the glDraw* functions care about is which vertex attribute arrays are enabled.

    int i = 0;
    while (i < vertices.length )
    {
        glDrawArrays(GL_LINE_LOOP, i, 6);  // mode, starting index, number of indices
        i += 6;
    }	
	
    glBindVertexArray(0);   
}




GLuint createSquareVAO(float[] verts)
{
    GLuint squareVAO;
    glGenVertexArrays(1, &squareVAO);
    glBindVertexArray(squareVAO); 

    GLuint squareVBO;
    glGenBuffers(1, &squareVBO);
    glBindBuffer(GL_ARRAY_BUFFER, squareVBO);  
    glBufferData(GL_ARRAY_BUFFER, cast(long) verts.bytes, verts.ptr, GL_STATIC_DRAW);  // upload (to GPU) the verts

    glEnableVertexAttribArray(0);	
	
	glVertexAttribPointer(
    0,         // index of the vertex attribute to be modified.    
    3,         // number of components per generic vertex attribute. Must be 1, 2, 3, 4.
    GL_FLOAT,  // data type of each component in the array
    GL_FALSE,  // normalized 
	0,         // tightly packed
	null       //cast(const(void)*) (0 * GLfloat.sizeof)  // offset of the first component of the first vertex attribute
	);
	
    glBindVertexArray(0);                // zero means to unbind the current vertex array (object)
    glDisableVertexAttribArray(0);       // disable all the enabled vertex attributes
    glBindBuffer(GL_ARRAY_BUFFER, 0);    // unbind the current array buffer and index buffer
	
    return squareVAO;  // The VAO was unbound but still exists
}



GLuint createHexBoardVAO(float[] vertices)  // Pass in 1 interleaved data array
{
    GLuint hexBoardVAO;
    glGenVertexArrays(1, &hexBoardVAO);
    glBindVertexArray(hexBoardVAO); 

    GLuint hexBoardVBO;                     // Need only one VBO since all data is interleaved within it
    glGenBuffers(1, &hexBoardVBO);
    glBindBuffer(GL_ARRAY_BUFFER, hexBoardVBO);  
    glBufferData(GL_ARRAY_BUFFER, cast(long) vertices.bytes, vertices.ptr, GL_STATIC_DRAW);  // upload (to GPU) the vertices
	
	
	// we have fed the data interspersed: xyzrgbxyzrgb... in one contiguous array. Need to demarcate the interleaved data

    // Before calling glVertexAttribPointer, you should bind the corresponding buffer (hexBoardVBO) right before (no 
    // matter when that was actually created and filled), since the glVertexAttribPointer function sets the currently 
    // bound GL_ARRAY_BUFFER as source buffer for this attribute 
	
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * GLfloat.sizeof, cast(const(void)*) (0 * GLfloat.sizeof));
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * GLfloat.sizeof, cast(const(void)*) (3 * GLfloat.sizeof));
    glEnableVertexAttribArray(1);	

    // Note: the 1st parameter in glVertexAttribPointer cooresponds to the shader in variables
	
	// layout (location = 0) in vec3 aPos;
    // layout (location = 1) in vec3 aColor;


    //glEnableVertexAttribArray(0);	
	//glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);  // before added color attribute
	
    glBindVertexArray(0);                // zero means to unbind the current vertex array (object)
    glDisableVertexAttribArray(0);       // disable all the position attribute
    glDisableVertexAttribArray(1);       // disable all the color attribute	
    glBindBuffer(GL_ARRAY_BUFFER, 0);    // unbind the current array buffer and index buffer
	
    return hexBoardVAO;  // The VAO was unbound but still exists
}

GLuint createSolidHexVAO(float[] verts, float[] colors)   // vertices are already configured as triangle ...
{
    GLuint solidVAO;
    glGenVertexArrays(1, &solidVAO);
    glBindVertexArray(solidVAO); 

    GLuint solidVBO;
    glGenBuffers(1, &solidVBO);
    glBindBuffer(GL_ARRAY_BUFFER, solidVBO);  
    glBufferData(GL_ARRAY_BUFFER, cast(long) verts.bytes, verts.ptr, GL_STATIC_DRAW);  // upload (to GPU) the verts

    glEnableVertexAttribArray(0);	// Vertex Shader:  layout (location = 0) in vec3 aPos;
	
	glVertexAttribPointer(
    0,         // Vertex Shader:  layout (location = 0) in vec3 aPos;    
    3,         // number of components per generic vertex attribute. Must be 1, 2, 3, 4.
    GL_FLOAT,  // data type of each component in the array
    GL_FALSE,  // normalized 
	0,         // tightly packed
	null       // cast(const(void)*) (0 * GLfloat.sizeof)  // offset of the first component of the first vertex attribute
	);


    GLuint colorVBO;
    glGenBuffers(1, &colorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, colorVBO);  
    glBufferData(GL_ARRAY_BUFFER, cast(long) colors.bytes, colors.ptr, GL_STATIC_DRAW);  // upload (to GPU) the verts

    glEnableVertexAttribArray(1);  // Vertex Shader: layout (location = 1) in vec3 aColor;
	
	glVertexAttribPointer(
    1,         // Vertex Shader: layout (location = 1) in vec3 aColor;  
    3,         // number of components per generic vertex attribute. Must be 1, 2, 3, 4.
    GL_FLOAT,  // data type of each component in the array
    GL_FALSE,  // normalized 
	0,         // tightly packed
	null       // cast(const(void)*) (0 * GLfloat.sizeof)  // offset of the first component of the first vertex attribute
	);

	
    glBindVertexArray(0);                // zero means to unbind the current vertex array (object)
    glDisableVertexAttribArray(0);       // disable all the enabled vertex attributes
	glDisableVertexAttribArray(1);       // disable all the enabled vertex attributes
    glBindBuffer(GL_ARRAY_BUFFER, 0);    // unbind the current array buffer and index buffer
	
    return solidVAO;  // The VAO was unbound but still exists
}