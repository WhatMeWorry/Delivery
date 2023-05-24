
module openglAbstractionLayers;

import dynamic_libs.opengl;  // GLuint, all the glXXXXX commands
import mytoolbox;     // without - Error: no property bytes for type float[]
                      // writeAndPause()  .bytes  .elements
					  
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
    int i = 0;
    while (i < vertices.length )
    {
        glDrawArrays(GL_LINE_LOOP, i, 12);  // mode, starting index, number of indices
        i += 12;
    }
    +/

    int i = 0;
    while (i < vertices.length )
    {
        glDrawArrays(GL_LINE_LOOP, i, 6);  // mode, starting index, number of indices
        i += 6;
    }	
	
    glBindVertexArray(0);   
}

GLuint createHexBoardVAO(float[] vertices)
{
    GLuint hexBoardVAO;
    glGenVertexArrays(1, &hexBoardVAO);
    glBindVertexArray(hexBoardVAO); 

    GLuint hexBoardVBO;
    glGenBuffers(1, &hexBoardVBO);
    glBindBuffer(GL_ARRAY_BUFFER, hexBoardVBO);  
    glBufferData(GL_ARRAY_BUFFER, cast(long) vertices.bytes, vertices.ptr, GL_STATIC_DRAW);  // upload (to GPU) the vertices

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * GLfloat.sizeof, cast(const(void)*) (0 * GLfloat.sizeof));
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * GLfloat.sizeof, cast(const(void)*) (3 * GLfloat.sizeof));
    glEnableVertexAttribArray(1);	


    //glEnableVertexAttribArray(0);	
	//glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, null);  // before added color attribute
	
    glBindVertexArray(0);                // zero means to unbind the current vertex array (object)
    glDisableVertexAttribArray(0);       // disable all the position attribute
    glDisableVertexAttribArray(1);       // disable all the color attribute	
    glBindBuffer(GL_ARRAY_BUFFER, 0);    // unbind the current array buffer and index buffer
	
    return hexBoardVAO;  // The VAO was unbound but still exists
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