
module app;  // 01_03_00_hexagon


import std.stdio;     // writeln

import shaders;       // without - Error: undefined identifier Shader, createProgramFromShaders, ...
import event_handler; // without - Error: undefined identifier onKeyEvent, onFrameBufferResize, handleEvent
import mytoolbox;     // without - Error: no property bytes for type float[]
 
import dynamic_libs.glfw;    // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;  // without - Error: undefined identifier load_openGL_Library




bool squares = false;
bool hexes = true;

GLfloat[] board;

// start at the bottom left corner of the NDC
GLfloat x = -1.0;
GLfloat y = -1.0;
GLfloat startX = -1.0;   // NDC Normalized Device Coordinates start at -1.0 and ends at 1.0 for all axes
GLfloat startY = -1.0;
 
immutable GLfloat deltaRun  = .50;
immutable GLfloat deltaRise = deltaRun * 0.866;  // hex is only .866 as tall as a unit 1.0 equilateral hex is wide

GLfloat halfRun  = deltaRun  * 0.5;
GLfloat quarRun  = deltaRun  * 0.25;
GLfloat halfRise = deltaRise / 2.0;

void drawHexagon()
{
    // initialize each hexagon 
    board ~= [x + quarRun, y, 0.0];
    board ~= [x + quarRun + halfRun, y, 0.0];
    board ~= [x + deltaRun, y + halfRise, 0.0];
    board ~= [x + quarRun + halfRun, y + deltaRise, 0.0]; 
    board ~= [x + quarRun, y + deltaRise, 0.0];
    board ~= [x, y + halfRise, 0.0];                       
}

void main(string[] argv)
{
    load_GLFW_Library();

    load_openGL_Library();  

    // window must be square

    auto winMain = glfwCreateWindow(800, 800, "01_03_00_hexagon", null, null);

    glfwMakeContextCurrent(winMain); 

    // you must set the callbacks after creating the window

                glfwSetKeyCallback(winMain, &onKeyEvent);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);

    Shader[] shaders =
    [
             Shader(GL_VERTEX_SHADER, "source/vertexShader.glsl",      0),
           Shader(GL_FRAGMENT_SHADER, "source/fragmentShader.glsl",    0)
        //       (GL_GEOMETRY_SHADER, "source/geometryShader.glsl"     0),
        //        (GL_COMPUTE_SHADER, "source/computeShader.glsl",     0),
        //   (GL_TESS_CONTROL_SHADER, "source/tessControlShader.glsl", 0), 
        //(GL_TESS_EVALUATION_SHADER, "source/tessEvalShader.glsl",    0)
    ];

    GLuint programID = createProgramFromShaders(shaders);

    writeln("programID = ", programID);

    // Set up vertex data (and buffer(s)) and attribute pointers
    GLfloat[] vertices = 
    [
        //  Positions         Colors      Texture Coords 		
    ];

    
    if (squares)
    { 
    while(x < 1.0)
    {
        while(y < 1.0)
        {
            // initialize each square 
            board ~= [x, y, 0.0];             // lower left corner
            board ~= [x + deltaRun, y, 0.0];  // lower right corner
            board ~= [x + deltaRun, y + deltaRise, 0.0];  // upper right corner
            board ~= [x, y + deltaRise, 0.0];  // upper left corner

            y += deltaRise;            
        }
        y = startY;
        x += deltaRun;
    }
    }


    if (hexes)
    { 


    bool stagger = false; 

    while(y < 1.0)
    {
        while(x < 1.0)
        {
            drawHexagon();
            stagger = !stagger;

            if (stagger)
                y += halfRise;
            else 
                y -= halfRise;   

            x += quarRun + halfRun;  
        }
        x = startX;       
        y += deltaRise;
    }  
    }

    writeln("board = ", board);
    writeln("board.length = ", board.length);

    vertices = board;

    GLuint VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);

    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.bytes, vertices.ptr, GL_STATIC_DRAW);


    enum describeBuff = defineVertexLayout!(int)([3]);
    mixin(describeBuff);
    pragma(msg, describeBuff);

    // Position attribute
    //glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * GLfloat.sizeof, cast(const(void)*) 0);
    //glEnableVertexAttribArray(0);

    // note that this is allowed, the call to glVertexAttribPointer registered VBO as the vertex 
	// attribute's bound vertex buffer object so afterwards we can safely unbind
    glBindBuffer(GL_ARRAY_BUFFER, 0); 

    // You can unbind the VAO afterwards so other VAO calls won't accidentally modify this VAO, but this rarely happens. Modifying other
    // VAOs requires a call to glBindVertexArray anyways so we generally don't unbind VAOs (nor VBOs) when it's not directly necessary.
    glBindVertexArray(0); 

    glUseProgram(programID);

    // uncomment this call to draw in wireframe polygons.
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);

    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions  
        handleEvent(winMain);   
        // Render
        
        // Clear the colorbuffer
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glBindVertexArray(VAO);  // seeing as we only have a single VAO there's no need to bind it every time, 
		                         // but we'll do so to keep things a bit more organized
        if (squares)
        { 
        int i = 0;
        while (i < vertices.length )
        {
            glDrawArrays(GL_LINE_LOOP, i, 4);
            i += 4;
        }
        }

        if (hexes)
        { 
        int i = 0;
        while (i < vertices.length )
        {
            glDrawArrays(GL_LINE_LOOP, i, 6);
            i += 6;
        }
        }


        // glBindVertexArray(0); // no need to unbind it every time 
 
        glfwSwapBuffers(winMain);
    }



    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}


