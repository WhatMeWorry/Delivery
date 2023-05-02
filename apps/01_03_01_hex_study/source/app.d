
module app;  // 01_03_01_hex_study


import std.stdio;     // writeln
import core.stdc.stdlib: exit;
import std.math.rounding: floor;
import shaders;       // without - Error: undefined identifier Shader, createProgramFromShaders, ...
import event_handler; // without - Error: undefined identifier onKeyEvent, onFrameBufferResize, handleEvent
import mytoolbox;     // without - Error: no property bytes for type float[]
 
import dynamic_libs.glfw;    // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;  // without - Error: undefined identifier load_openGL_Library

//              GLFW Cursor Coordinates (integer)
//    (x, y)
//    (1,1)-------------(800,1)
//      |                   |
//      |                   |
//      |                   |
//      |                   |
//      |                   |
//      |                   |
//      |                   |
//      |                   |
//    (1,800)-----------(800,800)
//
//
//              Normalized Device Coordinates (NDC) (floats)    
//    (x, y)   
// (-1.0,1.0)-----------(1.0,1.0)
//      |                   |
//      |                   |
//      |                   |
//      |     (0.0,0.0)     |
//      |         +         |
//      |                   |
//      |                   |
//      |                   |
//      |                   |
// (-1.0,-1.0)-----------(1.0,-1.0)
//  

//         HexBoard 2 Dimensional array layout
//                    
//    /           \    (1,1)  /           \    (1,3)  /           \
//   /    (1,0)    \_________/    (1,2)    \_________/             \
//   \             /         \             /         \     (1,4)   /
//    \           /           \           /           \           /
//     \_________/    (0,1)    \_________/    (0,3)    \_________/
//     /         \             /         \             /         \ 
//    /           \           /           \           /           \ 
//   /     (0,0)   \_________/    (0,2)    \_________/     (0,4)   \    
//   \             /         \             /         \             /
//    \           /           \           /           \           /
//     \_________/             \_________/             \_________/


//   Grid Rows
//
//    /           \    GridRow = 3        \           /           \
//   /_____________\_________/_____________\_________/_____________\
//   \             /         \             /         \             /
//    \           /           \       GridRow = 2     \           /
//   __\_________/_____________\_________/_____________\_________/__
//     /         \             /         \             /         \ 
//    /           \        GridRow = 1    \           /           \ 
//   /_____________\_________/_____________\_________/_____________\    
//   \             /         \             /         \             /
//    \         Grid Row = 0  \           /           \           /
//   __\_________/_____________\_________/_____________\_________/__

//   Grid Columns
//
//   | / grid    | \         | /         | \         | /         | \
//   |/  column  |  \________|/          |  \__grid__|/          |  \
//   |\     0    |  /        |\          |  /column  |\          |  /
//   | \         | /         | \         | /      3  | \         | /
//   |  \________|/    grid  |  \________|/          |  \________|/__
//   |  /        |\  column  |  /        |\          | grid      |\ 
//   | /         | \     1   | /         | \         | / column  | \ 
//   |/          |  \________|/  grid    |  \________|/      4   |  \    
//   |\          |  /        |\  column  |  /        |\          |  /
//   | \         | /         | \     2   | /         | \         | /
//   |  \________|/__________|__\________|/__________|__\________|/__
//      

extern(C) void mouseButtonCallback(GLFWwindow* winMain, int button, int action, int mods) nothrow
{
    try  // try is needed because of the nothrow
    {
        switch(button)
        {
            case GLFW_MOUSE_BUTTON_LEFT:
                if (action == GLFW_PRESS)
                {
                    double xPos, yPos;
                    glfwGetCursorPos(winMain, &xPos, &yPos);
                    writeln("x and y cursor position = ", xPos, " ", yPos);

                    double NDCx = (xPos / (winWidth / 2.0)) - 1.0;  // xPos/(winWidth/2.0) gives values from 0.0 to 2.0
                                                                    // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0 	
                    double NDCy = -((yPos / (winHeight / 2.0)) - 1.0); // xPos/(winHeight/2.0) gives values from 0.0 to 2.0
                                                                    // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0 	
                    // The minus sign is needed because screen coordinates are flipped horizontally from NDC coordinates																	
                    writeln("NDC x,y = ", NDCx, ",", NDCy);										

                    // Take the bottom of the edge of the scree (ie -1.0)  Any screen click on the screen is going to be Bigger in value.
					// So that the mouse click and subtract the edge.  
					
                    double offsetX = NDCx - 1.0;
					
                    double offsetFromBottom = NDCy - (-1.0);
                    writeln("offset From Bottom = ", offsetFromBottom);		
	
 	                double gridRow = floor(offsetFromBottom / apothem) + 1.0;
                    writeln("gridRow = ", gridRow);	


                    double offsetFromLeft = NDCx - (-1.0);
                    writeln("offset From Left = ", offsetFromLeft);							
                     
 	                double gridCol = floor(offsetFromLeft / (radius + halfRadius)) + 1.0;
                    writeln("gridCol = ", gridCol);						
	
                    //double gridCol = floor(NDCx / radius + halfRadius);
                    //writeln("gridCol = ", gridCol);	
                    //double gridRow = floor(NDCy / apothem);
                    //writeln("gridRow = ", gridRow);	
					
                }
                else if (action == GLFW_RELEASE)
                {
                    //mouseButtonLeftDown = false;
                }
			    break;
		    default: assert(0);
        }
    }
    catch(Exception e)
    {
    }
}




bool isOdd(uint value)
{
    return(!(value % 2) == 0); 
}

bool isEven(uint value)
{
    return((value % 2) == 0);   
}

struct D3_point
{
    GLfloat x;
    GLfloat y; 
    GLfloat z;
}

struct Hex
{
    D3_point[6] points;  // each hex is made up of 6 vertices
	bool selected;
}


//         rows = 1;  cols = 5;
//                    
//                  _________               _________              
//                 /         \             /         \     
//                /           \           /           \       
//      _________/    (0,1)    \_________/    (0,3)    \_________
//     /         \             /         \             /         \ 
//    /           \           /           \           /           \ 
//   /     (0,0)   \_________/    (0,2)    \_________/     (0,4)   \    
//   \             /         \             /         \             /
//    \           /           \           /           \           /
//     \_________/             \_________/             \_________/


//         rows = 3; cols = 1;
//      _________
//     /         \                  
//    /           \
//   /    (2,0)    \
//   \             /
//    \           /
//     \_________/          
//     /         \                  
//    /           \
//   /    (1,0)    \
//   \             /
//    \           /
//     \_________/ 
//     /         \
//    /           \ 
//   /    (0,0)    \
//   \             /
//    \           /
//     \_________/


struct HexBoard
{
    enum uint rows = 5;  // number of rows on the board [1..n]
    enum uint cols = 4;  // number of columns on the bord [1..n]
	
	double topOfHexesDrawn;

    Hex[cols][rows] board;  // Note: call with board[rows][cols];  // REVERSE ORDER!

    void displayHexBoard()
    {
        foreach(r; 0..rows)
        {
            foreach(c; 0..cols)
            {
			
                foreach(p; 0..6)
                {
                    //writeln("board(r,c) ) ", board[r][c].points[p] );                   
                }				 	
            }
        }			
    }
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

//      5_________4
//      /         \                
//     /           \
//   6/             \3    
//    \             /
//     \           /
//   |_ \_________/ 
// (x,y) 1        2

                              // x, y is the lower left corner of the rectangle touching all vertices
D3_point[6] defineHexVertices(GLfloat x, GLfloat y, GLfloat perpendicular, GLfloat diameter, GLfloat apothem, GLfloat halfRadius, GLfloat radius)
{
    D3_point[6] points;
	
	points[0].x = x + halfRadius;
	points[0].y = y;	
	points[0].z = 0.0;	

	points[1].x = x + halfRadius + radius;
	points[1].y = y;
	points[1].z = 0.0;		
		
	points[2].x = x + diameter;
	points[2].y = y + apothem;
	points[2].z = 0.0;		
	
	points[3].x = x + halfRadius + radius;
	points[3].y = y + perpendicular;
	points[3].z = 0.0;		
	
	points[4].x = x + halfRadius;
	points[4].y = y + perpendicular;
	points[4].z = 0.0;	
	
	points[5].x = x;
	points[5].y = y + apothem;
	points[5].z = 0.0;	
	
    return points;
} 




 
void defineHexagon(GLfloat perpendicular, GLfloat diameter, GLfloat apothem, GLfloat halfRadius, GLfloat radius)
{
    // initialize each hexagon 
	/+
    board ~= [x + halfRadius,          y,                 0.0];  // 1
    board ~= [x + halfRadius + radius, y,                 0.0];  // 2
    board ~= [x + diameter,            y + apothem,       0.0];  // 3
    board ~= [x + halfRadius + radius, y + perpendicular, 0.0];  // 4
    board ~= [x + halfRadius,          y + perpendicular, 0.0];  // 5
    board ~= [x,                       y + apothem,       0.0];  // 6
    +/	
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
//                 /         \             /         \             /
//                /           \           /           \           /
//      _________/___diameter__\_________/___diameter__\_________/
//     /         \             /         \             /         \ 
//    /           \           /           \           /           \ 
//   /__diameter___\_________/___diameter__\_________/___diameter__\    
//   \             /         \             /         \             /
//    \           /           \           /           \           /
//     \_________/___diameter__\_________/             \_________/
//   +
// -1.0           -.50            0.0            0.50              1.0



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
  
  
uint winWidth = 800;
uint winHeight = 800;

immutable GLfloat diameter = 0.3; // diameter is a user defined constant in NDC units, so needs to be between [0.0, 2.0)
                                  // which because of the hex board stagger makes a row of 5 (not 4) hexes.
                                  // A diameter of 2.0, would display a single hex which would fill the full width 
                                  // of the window and 0.866 of the windows height.
								  
immutable GLfloat radius = diameter * 0.5;	
immutable GLfloat halfRadius = radius * 0.5;	
									
immutable GLfloat perpendicular = diameter * 0.866;	
immutable GLfloat apothem = perpendicular * 0.5;
	
void main(string[] argv)
{
    writeln("******************************************************");
	
    HexBoard hexBoard;

    if (hexBoard.cols == 1)
        hexBoard.topOfHexesDrawn = hexBoard.rows * perpendicular;  // degenerate case  	
    else
        hexBoard.topOfHexesDrawn = (hexBoard.rows * perpendicular) + apothem;    

    hexBoard.topOfHexesDrawn -= 1.0;  // adjust for the NDC starting at -1.0 instead of 0.0
	

    //writeln("hexBoard.rows = ", hexBoard.rows);
    //writeln("hexBoard.cols = ", hexBoard.cols);	
    //writeln("perpendicular = ", perpendicular);	
    //writeln("hexBoard.topOfHexesDrawn = ", hexBoard.topOfHexesDrawn);
	
	double offsetFromHexesBottom = hexBoard.topOfHexesDrawn - (-1.0);
    writeln("offset From Hexes Bottom = ", offsetFromHexesBottom);		
	
 	double gridRows = offsetFromHexesBottom / apothem;
    writeln("gridRows = ", gridRows);	
    
	
	
    load_GLFW_Library();

    load_openGL_Library();  

    //load_libraries();


    // window must be square

    auto winMain = glfwCreateWindow(winWidth, winHeight, "01_03_01_hex_study", null, null);

    glfwMakeContextCurrent(winMain); 

    // you must set the callbacks after creating the window

                glfwSetKeyCallback(winMain, &onKeyEvent);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);
        glfwSetMouseButtonCallback(winMain, &mouseButtonCallback);


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
    // DEFINE HEXBOARD USING ROW/COLUMN of a 2 dimensional array (albeit staggered) 
    // ///////////////////////////
	
    // start at the bottom left corner of the NDC
    GLfloat x = -1.0;
    GLfloat y = -1.0;
    GLfloat startX = -1.0;   // NDC Normalized Device Coordinates start at -1.0 and ends at 1.0 for all axes

    hexBoard.displayHexBoard();		

    foreach(row; 0..hexBoard.rows)
    {
        foreach(col; 0..hexBoard.cols)
        {	
            hexBoard.board[row][col].points = defineHexVertices(x, y, perpendicular, diameter, apothem, halfRadius, radius);
			
            if (col.isEven)
            {
                y += apothem;
            }
            else
            {			
                y -= apothem;   
            }
            x += halfRadius + radius;  
        }

        x = startX;    
        if (hexBoard.cols.isOdd)
        {
            y -= apothem;
        }
        		
        y += perpendicular;	
    }  

    //hexBoard.displayHexBoard();		



    // Take the hexboard comprising a 2 dimensional array of hex objects and
	// convert it to a 1 dimensional array vertices.

    //vertices = board;  // obsolete

    foreach(row; 0..hexBoard.rows)
    {
        foreach(col; 0..hexBoard.cols)
        {
            foreach(p; 0..6)
            {
                vertices ~= hexBoard.board[row][col].points[p].x;  
                vertices ~= hexBoard.board[row][col].points[p].y;
                vertices ~= hexBoard.board[row][col].points[p].z;				
            }				 
        }
    }  	
    
	
	

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


