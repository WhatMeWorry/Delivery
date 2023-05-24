
// glBindBuffer(GL_ARRAY_BUFFER, 0);  /// buffer set to zero effectively unbinds any buffer object previously bound


// Way 1 - Each attribute a VBO.

// this format like : (xyzxyz...)(rgbrgb...)(stst....), and we can let both sride = 0 and offset = 0.

// Each attribute is tightly packed in each array. So stride = 0 which means tightly packed. 

/+

void prepareVertData_moreVBO(GLuint& VAOId, std::vector<GLuint>& VBOIdVec)
{
    GLfloat vertPos[] = {                  // positon
        -0.5f, 0.0f, 0.0f, 0.5f, 0.0f, 0.0f, 0.0f, 0.5f, 0.0f };

    GLfloat vertColor[] = {                // color
      1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f };

    GLfloat vertTextCoord[] = {            // texture coordinate
      0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f };
    
    GLuint VBOId[3];
    
    glGenVertexArrays(1, &VAOId);
    glBindVertexArray(VAOId);
    glGenBuffers(3, VBOId);

    // specify position attribute
    glBindBuffer(GL_ARRAY_BUFFER, VBOId[0]);  //  binds VBOId[0] to the GL_ARRAY_BUFFER binding
	
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertPos), vertPos, GL_STATIC_DRAW);
	
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, NULL);  // Use most recently bounded buffer
	
	// attribute index 0 gets its vertex array data from VBOId[0], because 
	// that's the buffer that was bound to GL_ARRAY_BUFFER when the glVertexAttribPointer was called.	


    glBindBuffer(GL_ARRAY_BUFFER, 0);
	
    // This line binds the buffer object 0 to the GL_ARRAY_BUFFER binding. What does this do to the association between attribute 0 and buf1?
    // Nothing! Changing the GL_ARRAY_BUFFER binding changes nothing about vertex attribute 0. Only calls to glVertexAttribPointer can do that.

    // Think of it like this. glBindBuffer sets a global variable, then glVertexAttribPointer reads that global variable and stores it in the VAO. 
    // Changing that global variable after it's been read doesn't affect the VAO. You can think of it that way because that's exactly how it works.

    // This is also why GL_ARRAY_BUFFER is not VAO state; the actual association between an attribute index and a buffer is made by glVertexAttribPointer.

    // Note that it is an error to call the glVertexAttribPointer functions if 0 is currently bound to GL_ARRAY_BUFFER.	
	
    glEnableVertexAttribArray(0);

    // specify color attribute
    glBindBuffer(GL_ARRAY_BUFFER, VBOId[1]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertColor), vertColor, GL_STATIC_DRAW);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(1);

    // specify texture coordinate attribute
    glBindBuffer(GL_ARRAY_BUFFER, VBOId[2]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertTextCoord), vertTextCoord, GL_STATIC_DRAW);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 0, NULL);
    glEnableVertexAttribArray(2);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    VBOIdVec.push_back(VBOId[0]);
    VBOIdVec.push_back(VBOId[1]);
    VBOIdVec.push_back(VBOId[2]);
}






// Way2 - Each attribute is sequential, batched in a single VBO.

// this format is: (xyzxyzxyz...rgbrgbrgb...stststst...), we can let stride=0 but offset should be specified.

// Each attribute is tightly packed in the array. So stride = 0 which means tightly packed but offset must be specified.

void prepareVertData_seqBatchVBO(GLuint& VAOId, std::vector<GLuint>& VBOIdVec)
{
    GLfloat vertices[] = {
      -0.5f, 0.0f, 0.0f, 0.5f, 0.0f, 0.0f, 0.0f, 0.5f, 0.0f,  // position
       1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f,  // color
       0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f                     // texture coordinate
    };
    
    GLuint VBOId;
    glGenVertexArrays(1, &VAOId);
    glBindVertexArray(VAOId);
    
    glGenBuffers(1, &VBOId);
    glBindBuffer(GL_ARRAY_BUFFER, VBOId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // specifiy position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, (GLvoid*)0); // stride can also be 3 * sizeof(GLfloat)
    glEnableVertexAttribArray(0);

    // specify color attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 0, (GLvoid*)(9 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);

    // specify texture coordinate
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 0, (GLvoid*)(18 * sizeof(GLfloat)));
    glEnableVertexAttribArray(2);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    VBOIdVec.push_back(VBOId);
}




// Way 3 - Interleaved attributes in a single VBO

// this format is like: (xyzrgbstxyzrgbst...),we have to manually specify the offset and stride

// Each attribute is interleaved in the array. So stride = 0 which means tightly packed but offset must be specified.

void prepareVertData_interleavedBatchVBO(GLuint& VAOId, std::vector<GLuint>& VBOIdVec)
{
    // interleaved data
    GLfloat vertices[] = {
        -0.5f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f,  // 0
         0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f,  // 1
         0.0f, 0.5f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f,  // 2
    };
    
    GLuint VBOId;
    glGenVertexArrays(1, &VAOId);
    glBindVertexArray(VAOId);
    glGenBuffers(1, &VBOId);
    glBindBuffer(GL_ARRAY_BUFFER, VBOId);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // specify position attribute
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat),(GLvoid*)0);
    glEnableVertexAttribArray(0);

    // specify color attribute
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat),(GLvoid*)(3 * sizeof(GLfloat)));
    glEnableVertexAttribArray(1);

    // specify texture coordinate
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(GLfloat),(GLvoid*)(6 * sizeof(GLfloat)));
    glEnableVertexAttribArray(2);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);

    VBOIdVec.push_back(VBOId);
}

+/