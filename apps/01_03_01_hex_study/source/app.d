
module app;  // 01_03_01_hex_study


import std.stdio;     // writeln
import core.stdc.stdlib: exit;

import shaders;       // without - Error: undefined identifier Shader, createProgramFromShaders, ...
import event_handler; // without - Error: undefined identifier onKeyEvent, onFrameBufferResize, handleEvent
import mytoolbox;     // without - Error: no property bytes for type float[]
 
import dynamic_libs.glfw;    // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;  // without - Error: undefined identifier load_openGL_Library


GLfloat[] board;

// start at the bottom left corner of the NDC
GLfloat x = -1.0;
GLfloat y = -1.0;
GLfloat startX = -1.0;   // NDC Normalized Device Coordinates start at -1.0 and ends at 1.0 for all axes
GLfloat startY = -1.0;   // the board will be drawn starting from the lower left corner of screen
 
struct Delta
{
    GLfloat rise;
    GLfloat run;
    //GLfloat ratio;  // rise/run 
}

void quitOrContinue()
{		
    writeln("Press Enter key to continue or Q/q to quit");
    char c;
    readf("%c", &c);
    if ((c == 'Q') || (c == 'q'))
    {
        exit(0);	
    }
    return;
}	


// OpenGL by default determines a triangle to be facing towards the camera if the triangle's vertexes are 
// ordered in a counterclockwise order from the perspective of the camera

void defineHexagon(Delta delta, GLfloat halfRise, GLfloat quarRun, GLfloat radius)
{
    // initialize each hexagon 
    board ~= [x + quarRun,          y,              0.0];
    board ~= [x + quarRun + radius, y,              0.0];
    board ~= [x + delta.run,        y + halfRise,   0.0];
    board ~= [x + quarRun + radius, y + delta.rise, 0.0]; 
    board ~= [x + quarRun,          y + delta.rise, 0.0];
    board ~= [x,                    y + halfRise,   0.0];                       
}

// https://www.redblobgames.com/
// https://www.redblobgames.com/grids/hexagons/

//  if diameter = 0.5 and the hexagons were laid out horizontally with flat-top orientatation,
//  on a normalized device coordinated, four hexagons could fit. However, our hexboard
//  will have the hexagons staggered so they become form fitting.
//      _________      _________      _________      _________
//     /         \    /         \    /         \    /         \ 
//    /           \  /           \  /           \  /           \ 
//   /__diameter___\/__diameter___\/___diameter__\/__diameter___\    
//   \             /\             /\             /\             /
//    \           /  \           /  \           /  \           /
//     \_________/    \_________/    \_________/    \_________/ 
// -1.0           -.50            0.0            0.50          1.0

// The x and y axis is in Normalized Device Coordinates (NDC). Both lie between -1.0 and 1.0
// 


// diameter is the length from one vertex to the vertex opposite.
// Because the hex board has staggered columns, diameter = .50 makes a row of 5 columns (not 4) of hexes.
//                  _________               _________
//                 /         \             /         \
//                /           \           /           \
//      _________/             \_________/___diameter__\_________
//     /         \             /         \             /         \ 
//    /           \           /           \           /           \ 
//   /__diameter___\_________/___diameter__\_________/___diameter__\    
//   \             /         \             /         \             /
//    \           /           \           /           \           /
//     \_________/___diameter__\_________/             \_________/
//               \             /         \             /
//                \           /           \           /
//                 \_________/             \_________/ 
// -1.0           -.50            0.0            0.50          1.0


//     -.134  _ _ \____|____/ 
//                /    |    \             
//               /     |     \
//              /      |      \  
//              \      |      /   
//               \     | perpendicular
//     -.567 _ _  \____|____/ 
//                /    |    \             
//               /     |     \
//              /      |      \  
//              \      |      /   
//               \     | perpendicular
//     -1.0 _ _ _ \____|____/ 
//


// apothem - a line from the center of a regular polygon at right angles to any of its sides.
// radius - is the line (distance) from the center to any vertex of a regular polygon

// The hex polygon is not square. The hex apothem is 0.866 the length of the hex radius.
//      _________ 
//     /    |    \                
//    /     |<apothem 
//   /______|______\    
//   \          ^radius
//    \           /
//     \_________/ 
//
//    

// The diameter of a polygon is the largest distance between any pair of vertices. In other words, 
// it is the length of the longest polygon diagonal.
//
// diameter = 2 * radius
// perpendicular = 2 * apothem
//      _________          _________ 
//     /         \        /    |    \             
//    /           \      /     |     \
//   /_____________\    /      |      \  
//   \  diameter   /    \      |      /   
//    \           /      \     | perpendicular
//     \_________/        \____|____/ 
//
//    


const GLfloat diameter = 0.30;  // diameter is a user defined constant in NDC units, so needs to be between [0.0, 2.0)
                                // which because of the hex board stagger makes a row of 5 (not 4) hexes.
                                // A diameter of 2.0, would display a single hex which would fill the full width 
                                // of the window and 0.866 of the windows height.
void main(string[] argv)
{
    Delta delta;

    delta.run  = diameter;
    delta.rise = delta.run * 0.866;  // a hex is only .8660 as tall as a unit 1.0 hex is wide
	


    
	GLfloat perpendicular = diameter * .866;
	GLfloat apothem = perpendicular *0.5;
	
	GLfloat radius = diameter * 0.5;	
	
    GLfloat halfRise = delta.rise * 0.5;  
	
	
    GLfloat quarRun  = delta.run  * 0.25;
    GLfloat halfSide = perpendicular * 0.25;

    load_GLFW_Library();

    load_openGL_Library();  

    //load_libraries();


    // window must be square

    auto winMain = glfwCreateWindow(800, 800, "01_03_01_hex_study", null, null);

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


	// ///////////////////////////
    // DEFINE HEX BOARD VERTICES
	// //////////////////////////
    
	bool stagger = false; 

    while(y < 1.0)
    {
	    //writeln("y = ", y);
        while(x < 1.0)
        {
            defineHexagon(delta, halfRise, quarRun, radius);
            stagger = !stagger;

            if (stagger)
                y += halfRise;
            else 
                y -= halfRise;   

            x += quarRun + radius;  
        }
        x = startX;        		
        y += delta.rise;
		
		//quitOrContinue();
		
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

        int i = 0;
        while (i < vertices.length )
        {
            glDrawArrays(GL_LINE_LOOP, i, 6);
            i += 6;
        }
 
        // glBindVertexArray(0); // no need to unbind it every time 
 
        glfwSwapBuffers(winMain);
    }



    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}



