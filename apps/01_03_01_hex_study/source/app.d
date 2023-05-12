
module app;  // 01_03_01_hex_study

import std.conv: roundTo;
import std.stdio: writeln, readf;
import core.stdc.stdlib: exit;

import std.math.rounding: floor;
import std.math.algebraic: abs;

import shaders;       // without - Error: undefined identifier Shader, createProgramFromShaders, ...
import event_handler; // without - Error: undefined identifier onKeyEvent, onFrameBufferResize, handleEvent
import mytoolbox;     // without - Error: no property bytes for type float[]
 
import dynamic_libs.glfw;    // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;  // without - Error: undefined identifier load_openGL_Library

//              GLFW Cursor Coordinates (integer)
//    (x, y)
//    (1,1)-------------(800,1)
//      | mouse             |
//      | clicking inside   |
//      | the window will   |  (notice how the counting
//      | return            |   starts in the upper
//      | coordinates       |   left hand corner)
//      | within these      |
//      | ranges            |
//      |                   |
//    (1,800)-----------(800,800)
//
//
//              Normalized Device Coordinates (NDC) (floats)    
//    (x, y)   
// (-1.0,1.0)-----------(1.0,1.0)
//      |                   |
//      |                   |
//      |                   |  OpenGL uses NDC coordinate.
//      |     (0.0,0.0)     |
//      |         +         |
//      |                   |
//      |                   |
//      |                   |
//      |                   |
// (-1.0,-1.0)-----------(1.0,-1.0)
//

struct D3_point
{
    double x;
    double y; 
    double z;
}
  
D3_point NDC;        // will just use the x,y coordinates (not z)
D3_point hexCenter;  // will just use the x,y coordinates (not z)


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
//    /           \    grid row 3         \           /           \
//   /_____________\_________/_____________\_________/_____________\
//   \             /         \             /         \             /
//    \           /           \       grid row = 2    \           /
//   __\_________/_____________\_________/_____________\_________/__
//     /         \             /         \             /         \ 
//    /           \        grid row 1     \           /           \ 
//   /_____________\_________/_____________\_________/_____________\    
//   \             /         \             /         \             /
//    \         grid row 0    \           /           \           /
//   __\_________/_____________\_________/_____________\_________/__



//   Grid Columns
//
//   |  \________|/          |  \________|/          |  \________|/__
//   |  /        |\          |  /        |\          |  /        |\ 
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



bool isOdd(uint value)
{
    return(!(value % 2) == 0); 
}

bool isEven(uint value)
{
    return((value % 2) == 0);   
}



struct Hex
{
    D3_point[6] points;  // each hex is made up of 6 vertices
    bool selected;       // set to true whenever mouse clicks on this particular hex
    D3_point center;     // each hex has a center
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


struct Edges
{                // This is the hex board edges, not the window's
    double top;
    double bottom; 
    double left;
    double right;	
}

struct HexBoard
{
    enum uint rows = 5;  // number of rows on the board [0..rows-1]
    enum uint cols = 5;  // number of columns on the bord [0..cols-1]
	
    Edges edge;

    // diameter is a user defined constant in NDC units, so needs to be between [0.0, 2.0)
    // which because of the hex board stagger makes a row of 5 (not 4) hexes.
    // A diameter of 2.0, would display a single hex which would fill the full width 
    // of the window and 0.866 of the windows height.

    double diameter;  // diameter, along with rows and cols are critical to definition of a HexBoard 

    double radius;	
    double halfRadius;	
									
    double perpendicular;	
    double apothem;

    Hex[cols][rows] hexes;  // Note: call with hexes[rows][cols];  // REVERSE ORDER!    

    void displayHexBoard()
    {
        foreach(r; 0..rows)
        {
            foreach(c; 0..cols)
            {
                writeln("hexes[", r, "][", c, "].center ", hexes[r][c].center );    
				
                foreach(p; 0..6)
                {
                    //writeln("hexes(r,c) ) ", hexes[r][c].points[p] );                   
                }				 	
            }
        }			
    }
}




// The hexboard's layout is started in the lower left hand corner.
// If the window is bigger than the hexboard, you will see empty
// band of space along the window top and/or window right edge.
// Mouse clicking on these bands will cause the program to abend
// during execution with an array index out-of-bounds error.
// we use the 

//  left edge of window                                 + right edge of hexboard
//  |                                                   |
//  V_______________________top edge of window__________|_______ 
//  |                                                   |       |
//  |                                                   |       |
//  |                                                   |       |
//  |___________________________________________________|_______|_____top edge of hexboard                                                         |
//  |\             /         \             /         \  |       | 
//  | \           /           \           /           \ |       |
//  |  \_________/             \_________/             \|       |
//  |  /         \             /         \             /|       | 
//  | /           \           /           \           / |       |right edge of window
//  |/             \_________/             \_________/  |       |
//  |\             /         \             /         \  |       |
//  | \           /           \           /           \ |       |
//  |  \_________/             \_________/             \|       |
//  |  /         \             /         \             /|       |
//  | /           \           /           \           / |       |
//  |/             \_________/             \_________/  |       |    
//  |\             /         \             /         \  |       |
//  | \           /           \           /           \ |       |
//  |__\_________/_____________\_________/_____________\|_______|
//                          bottom edge of window




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







//   |  \________|/          |  \________|/          |  \________|/
//   |XX/        |\          |XX/        |\          |XX/        |\ 
//   |X/         | \         |X/         | \         |X/         | \ 
//   |/          |  \________|/          |  \________|/          |  \    
//   |\          |XX/        |\          |XX/        |\          |XX/
//   | \         |X/         | \         |X/         | \         |X/
//   |  \________|/          |  \________|/          |  \________|/
//   |XX/        |\          |XX/        |\          |XX/        |\ 
//   |X/         | \         |X/         | \         |X/         | \ 
//   |/          |  \________|/          |  \________|/          |  \    
//   |\          |XX/        |\          |XX/        |\          |XX/
//   | \         |X/         | \         |X/         | \         |X/
//   |  \________|/__________|__\________|/__________|__\________|/__
// 
//            opposite 
//           __________
//           |......../         
//           |......./        
//           |....../           
//           |...../           
//  adjacent |..../            
//           |.../             
//           |../ 60 degrees   
//           |./  
//           |/
//           +         
//           leftPoint



//   |  /        |\          |  /        |\          |  /        |\ 
//   | /         |X\         | /         |X\         | /         |X\ 
//   |/          |XX\________|/          |XX\________|/          |XX\
//   |\          |  /        |\          |  /        |\          |  /
//   |X\         | /         |X\         | /         |X\         | /
//   |XX\________|/          |XX\________|/          |XX\________|/__
//   |  /        |\          |  /        |\          |  /        |\ 
//   | /         |X\         | /         |X\         | /         |X\ 
//   |/          |XX\________|/          |XX\________|/          |XX\    
//   |\          |  /        |\          |  /        |\          |  /
//   |X\         | /         |X\         | /         |X\         | /
//   |XX\________|/__________|XX\________|/__________|XX\________|/__
//
//           + leftPoint
//           |\      
//           |.\
//           |..\ 300 degrees
//           |...\
//           |....\     if angle < tan(300) then mouse clicked
//  adjacent |.....\    inside the triangle
//           |......\ 
//           |.......\     
//           |________\
// 
//            opposite         


bool clickedInSmallTriangle(D3_point mouseClick, D3_point hexCenter)
{
    immutable double tanOf60  =  1.7320508;
    immutable double tanOf300 = -1.7320508;

    double leftPointX = hexCenter.x - hexBoard.radius;
    double leftPointY = hexCenter.y;    

    double adjacent = mouseClick.x - leftPointX;
    double opposite = mouseClick.y - leftPointY;
	
    // tan(theta) = opposite / adjacent     
	
    double angle = opposite / adjacent;  // opposite is positive for hex sides /
	                                     // opposite is negative for hex sides \
    if (angle >= 0.0)            
        return (angle > tanOf60);    // angle is positive
    else                           
        return (angle < tanOf300);	 // angle is negative
}


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
                    //writeln("x and y cursor position = ", xPos, " ", yPos);

                    NDC.x =   (xPos /  (winWidth / 2.0)) - 1.0;  // xPos/(winWidth/2.0) gives values from 0.0 to 2.0
                                                                    // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0 	
                    NDC.y = -((yPos / (winHeight / 2.0)) - 1.0); // yPos/(winHeight/2.0) gives values from 0.0 to 2.0
                                                                    // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0 	
                    // The minus sign is needed because screen coordinates are flipped horizontally from NDC coordinates																	
 							
                    // Take the bottom of the edge of the screen (ie -1.0)  Any screen click on the screen is going to be Bigger in value.
					// So that the mouse click and subtract the edge.  
										
                    double offsetFromBottom = NDC.y - (-1.0);
	
					uint gridRow = roundTo!uint(floor(offsetFromBottom / hexBoard.apothem));

                    double offsetFromLeft = NDC.x - (-1.0);						
                     
					uint gridCol = roundTo!uint(floor(offsetFromLeft / (hexBoard.radius + hexBoard.halfRadius)));


                    if (NDC.x > hexBoard.edge.right)  // clicked to the right of the hex board's right edge
                    {
                        writeln("Clicked outside of the hex board's right edge");
                        return;						
                    }
                    if (NDC.y > hexBoard.edge.top)    // clicked above the hex board's top edge
                    {
                        writeln("Clicked above the hex board's top edge");
                        return;						
                    }

                    //   Grid Quandrants
                    // Quadrant is defined by (gridRow, gridCol) pair.
                    // Quad UL = (odd, even) 
                    //      LL = (even, even)
                    //      UR = (odd, odd)
                    //      LR = (even, odd)      
                    //
                    //   |__\________|/__________|__\________|/__________|__\________|/__
                    //   |  /        |\          |  /        |\          |  /        |\ 
                    //   | Upper Left|Upper Right| Upper Left|Upper Right| Upper Left| Upper Right
                    //   |/__________|__\________|/__________|__\________|/__________|__\
                    //   |\          |  /        |\          |  /        |\          |  /
                    //   | Lower Left|Lower Right|Lower Left |Lower Right| Lower Left| Lower Right
                    //   |__\________|/__________|__\________|/__________|__\________|/__
                    //   |  /        |\          |  /        |\          |  /        |\ 
                    //   |Upper Left |Upper Right| Upper Left|Upper Right| Upper Left| Upper Right
                    //   |/__________|__\________|/__________|__\________|/__________|  \    
                    //   |\          |  /        |\          |  /        |\          |  /
                    //   |Lower Left |Lower Right| Lower Left|Lower Right| Lower Left| Lower Right
                    //   |__\________|/__________|__\________|/__________|__\________|/__

                    // We can exclude 3/4 of the hexBoard just by finding the quadrant that was mouse clicked on

                    enum Quads { UL, UR, LL, LR }
                    Quads quadrant;

                    if (gridRow.isEven)
					{
					    if (gridCol.isEven)
                            quadrant = Quads.LL; // (e,e)
                        else
                            quadrant = Quads.LR; // (e,o)					
					}
                    else // gridRow isOdd
					{
					    if (gridCol.isEven)
                            quadrant = Quads.UL; // (o,e)
                        else
                            quadrant = Quads.UR; // (o,o)					
					}

                    enum invalid = -1;  // -1 means a row or column is invalid

                    int row = invalid;
                    int col = invalid;					

                    //================================= UL ========================================= 
  
                    if (quadrant == Quads.UL)   // Upper Left Quadrant
                    { 					
                        row = (gridRow-1) / 2;  // UL gridRows = {1, 3, 5, 7,...} mapped to row = {0, 1, 2, 3,...}
                        col = gridCol;

                        hexCenter = hexBoard.hexes[row][col].center;					

                        if (clickedInSmallTriangle(NDC, hexCenter))	 					
                        {
                            if(col == 0)
							{
                                row = invalid; 
                                col = invalid;
                            }
                            else
                            {
                                col -= 1;							   
                            }
                        }							
					}	

                    //================================= LR ========================================= 
						
                    if (quadrant == Quads.LR)    // Lower Right Quadrant
                    {
                        if (gridRow >= 1)  
                        {
					        row = (gridRow/2) - 1;    // LR gridRows = {2, 4, 6, 8,...}  mapped to row = {0, 1, 2, 3,...}
                            col = gridCol;	          //                0 handled by else block below				
 
                            hexCenter = hexBoard.hexes[row][col].center;

							if (clickedInSmallTriangle(NDC, hexCenter))
                            {
							    row += 1;
                                col -= 1;
                            }						    
                        }
                        else   // degenerate case, only for very bottom row on hexboard
                        {							
                            row = 0; 
                            col = gridCol;
							
                            hexCenter = hexBoard.hexes[row][col].center;
							
							hexCenter.y = (hexCenter.y - hexBoard.perpendicular);
						
                            if (clickedInSmallTriangle(NDC, hexCenter))
                            {
                                col -= 1;
                            }
                            else
                            {
                                row = invalid; 
                                col = invalid;							
                            }
                        }
					}							

                    //================================= UR =========================================						
						
                    if (quadrant == Quads.UR)    // Upper Right Quadrant
                    { 
					    row = (gridRow-1) / 2;    // UR gridRows = {1, 3, 5, 7,...} mapped to row = {0, 1, 2, 3,...}
                        col = gridCol;					
 
                        hexCenter = hexBoard.hexes[row][col].center;

						if (clickedInSmallTriangle(NDC, hexCenter))
                        {
                            col -= 1;
                        }						
					}													
						
                    //================================= LL =========================================						
						
                    if (quadrant == Quads.LL)    // Lower Left Quadrant
                    { 
                        row = gridRow / 2;    // gridRows = {0, 2, 4, 6,...} mapped to row = {0, 1, 2, 3,...}
                        col = gridCol;	

                        hexCenter = hexBoard.hexes[row][col].center;

                        if (clickedInSmallTriangle(NDC, hexCenter))
                        { 
                            if (gridRow == 0 || gridCol == 0)  // degenerate case, clicked on left side or 
                            {                                  // bottom of hexboard outside of any hex
                                row = invalid, 
                                col = invalid;
                            }
                            else
                            {
                                row -= 1;
                                col -= 1;								
                            }
                        }
                    }	

                    if ((row != invalid) && (col != invalid))
                    {
                        writeln("hex(row,col) = ", row, " ", col, " has been selected");					
                        hexBoard.hexes[row][col].selected = true;
                    }						
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



// OpenGL by default determines a triangle to be facing towards the camera if the triangle's vertexes are 
// ordered in a counterclockwise order from the perspective of the camera

//      4_________3
//      /         \                
//     /           \
//   5/             \2    
//    \             /
//     \           /
//   |_ \_________/ 
// (x,y) 0        1

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

D3_point defineHexCenter(GLfloat x, GLfloat y, GLfloat apothem, GLfloat radius)
{
    D3_point center;
	
	center.x = x + radius;
	center.y = y + apothem;
    center.z = 0.0;
	
    return center;
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


HexBoard hexBoard;
				
	
void main(string[] argv)
{

    // diameter is a user defined constant in NDC units, so needs to be between [0.0, 2.0)
    // which because of the hex board stagger makes a row of 5 (not 4) hexes.
    // A diameter of 2.0, would display a single hex which would fill the full width 
    // of the window and 0.866 of the windows height.

    hexBoard.diameter      = 0.43;  
								  
    hexBoard.radius        = (hexBoard.diameter * 0.5);	
    hexBoard.halfRadius    = (hexBoard.radius * 0.5);	
									
    hexBoard.perpendicular = (hexBoard.diameter * 0.866);	
    hexBoard.apothem       = (hexBoard.perpendicular * 0.5);

    // the topEdge will cut off half of the hex tops for odd columns but this is better
    // than causing an array index out of bounds run time error.

    // top edge = bottom edge of board + all the rows in board
    // NDC bottom edge = -1.0
	
    //hexBoard.topEdge = -1.0 + (hexBoard.rows * hexBoard.perpendicular);
	
	hexBoard.edge.bottom = -1.0;

    hexBoard.edge.top = hexBoard.edge.bottom + (hexBoard.rows * hexBoard.perpendicular); 

    // right edge = left edge of board + all the columns in board gives 
    // NDC left edge = -1.0
	
    //hexBoard.rightEdge = -1.0 + (hexBoard.cols * (hexBoard.radius + hexBoard.halfRadius)); 

	hexBoard.edge.left = -1.0;

    hexBoard.edge.right = hexBoard.edge.left + (hexBoard.cols * (hexBoard.radius + hexBoard.halfRadius)); 	
	
    load_GLFW_Library();

    load_openGL_Library();  



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



    // DEFINE HEX BOARD
 	
    // start at the bottom left corner of the window, drawing from left to right,
    // bottom to top.
	
    double x = hexBoard.edge.left;      // NDC Normalized Device Coordinates start at -1.0
    double y = hexBoard.edge.bottom;    
  
    foreach(row; 0..hexBoard.rows)
    {
        foreach(col; 0..hexBoard.cols)
        {	
            hexBoard.hexes[row][col].points = defineHexVertices(x, 
			                                                    y, 
																hexBoard.perpendicular, 
			                                                    hexBoard.diameter, 
															    hexBoard.apothem, 
															    hexBoard.halfRadius, 
															    hexBoard.radius);
			
            hexBoard.hexes[row][col].center = defineHexCenter(x, 
			                                                  y, 
															  hexBoard.apothem, 
															  hexBoard.radius);
            hexBoard.hexes[row][col].selected = false;			
            if (col.isEven)
            {
                y += hexBoard.apothem;
            }
            else
            {			
                y -= hexBoard.apothem;   
            }
            x += hexBoard.halfRadius + hexBoard.radius;  
        }
		
        x = hexBoard.edge.left;  // start a new row and column
		
        if (hexBoard.cols.isOdd)
        {
            y -= hexBoard.apothem;
        }
        		
        y += hexBoard.perpendicular;	
    }  

    hexBoard.displayHexBoard();		



    // Take the hexboard comprising a 2 dimensional array of hex objects and
	// convert it to a 1 dimensional array vertices.

    //vertices = hexes;  // obsolete

    foreach(row; 0..hexBoard.rows)
    {
        foreach(col; 0..hexBoard.cols)
        {
            foreach(p; 0..6)
            {
                vertices ~= hexBoard.hexes[row][col].points[p].x;  
                vertices ~= hexBoard.hexes[row][col].points[p].y;
                vertices ~= hexBoard.hexes[row][col].points[p].z;				
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
	pragma(msg, "===== See in Compiler Output =====");
    pragma(msg, describeBuff);
	
    /+ 
    The describeBuff enum creates the following two lines of code:
	
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * GLfloat.sizeof, cast(const(void)*) (0 * GLfloat.sizeof));
    glEnableVertexAttribArray(0);	
    +/
	

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







