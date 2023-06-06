
module app;  // 01_03_01_hex_study_vao_color

import std.conv: roundTo;
import std.stdio: writeln, readf;
import core.stdc.stdlib: exit;

import std.math.rounding: floor;
import std.math.algebraic: abs;

import std.random: uniform, Random, unpredictableSeed;

import shaders;       // without - Error: undefined identifier Shader, createProgramFromShaders, ...
import event_handler; // without - Error: undefined identifier onKeyEvent, onFrameBufferResize, handleEvent
import mytoolbox;     // without - Error: no property bytes for type float[]
                      // writeAndPause()  .bytes  .elements
import openglAbstractionLayers;  // createHexBoardVAO
 
import dynamic_libs.glfw;    // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;  // without - Error: undefined identifier load_openGL_Library

//              GLFW Cursor Coordinates (integer)
//    (x, y)
//    (1,1)-------------(800,1)
//      | mouse             |
//      | clicking inside   |
//      | the window will   |  (notice how the counting
//      | return            |   starts in the upper
//      | coordinates       |   left hand corner and
//      | within these      |   ends in the lower right
//      | ranges            |   corner)
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

struct D3_Point
{
    float x;
    float y; 
    float z;
}

struct D3_Color
{
    float r;
    float g; 
    float b;	
}

struct SelectedPair
{
    int row;
    int col;
}
  
D3_Point NDC;        // will just use the x,y coordinates (not z)
D3_Point hexCenter;  // will just use the x,y coordinates (not z)

enum invalid = -1;  // -1 means a row or column is invalid

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



struct Hex  // every hex of the board has the following characteristics:
{
    D3_Point[6] points;  // each hex is made up of 6 vertices of position data
    D3_Color[6] colors;  // each hex has 6 vertices of color data	
    D3_Point center;     // each hex has a center
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
    float top;   // The hex board can be smaller or larger than the window
    float bottom; 
    float left;
    float right;	
}

struct HexLengths
{
    float diameter;  // diameter is used to define calculate all the other lengths in this structure
    float radius;    	
    float halfRadius;								
    float perpendicular;	
    float apothem;
}

struct HexBoard
{
    enum uint rows = 3;  // number of rows on the board [0..rows-1]
    enum uint cols = 3;  // number of columns on the bord [0..cols-1]
	
    Edges edge;

    // diameter is a user defined constant in NDC units, so needs to be between [0.0, 2.0)
    // which because of the hex board stagger makes a row of 5 (not 4) hexes.
    // A diameter of 2.0, would display a single hex which would fill the full width 
    // of the window and 0.866 of the window's height.

    HexLengths hex;

                            // the hex board is made up of many hexes
    Hex[cols][rows] hexes;  // Note: call with hexes[rows][cols];  // REVERSE ORDER!   

    SelectedPair selected;	
	D3_Point[4] squarePts;
	

    void displayHexBoard()
    {
        foreach(r; 0..rows)
        {
            foreach(c; 0..cols)
            {
                writeln("hexes[", r, "][", c, "].center ", hexes[r][c].center );    
				
                foreach(p; 0..6)  // position then color
                {
                    writeln("hexes(r,c).points ) ", hexes[r][c].points[p] );
                    writeln("hexes(r,c).colors ) ", hexes[r][c].colors[p] );					
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
//           |....../  if angle > tan(60) then mouse clicked         
//           |...../   inside the triangle         
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


bool clickedInSmallTriangle(D3_Point mouseClick, D3_Point hexCenter)
{
    immutable float tanOf60  =  1.7320508;
    immutable float tanOf300 = -1.7320508;

    float leftPointX = hexCenter.x - hexBoard.hex.radius;
    float leftPointY = hexCenter.y;    

    float adjacent = mouseClick.x - leftPointX;
    float opposite = mouseClick.y - leftPointY;
	
    // tan(theta) = opposite / adjacent     
	
    float angle = opposite / adjacent;  // opposite is positive for hex sides /  (leaning Southwest to Northeast)
	                                     // opposite is negative for hex sides \  (leaning Northwest to Southeast)
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
                    glfwGetCursorPos(winMain, &xPos, &yPos);  // glfwGetCursorPos returns double mouse position
					
                    //writeln("x and y cursor position = ", xPos, " ", yPos);

                    NDC.x =   (xPos /  (winWidth / 2.0)) - 1.0;  // xPos/(winWidth/2.0) gives values from 0.0 to 2.0
                                                                    // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0 	
                    NDC.y = -((yPos / (winHeight / 2.0)) - 1.0); // yPos/(winHeight/2.0) gives values from 0.0 to 2.0
                                                                    // - 1.0   maps 0.0 to 2.0 to -1.0 to 1.0 	
                    // The minus sign is needed because screen coordinates are flipped horizontally from NDC coordinates																	
 							
                    // Take the bottom of the edge of the screen (ie -1.0)  Any screen click on the screen is going to be Bigger in value.
					// So that the mouse click and subtract the edge.  
										
                    float offsetFromBottom = NDC.y - (-1.0);
	
					uint gridRow = roundTo!uint(floor(offsetFromBottom / hexBoard.hex.apothem));

                    float offsetFromLeft = NDC.x - (-1.0);						
                     
					uint gridCol = roundTo!uint(floor(offsetFromLeft / (hexBoard.hex.radius + hexBoard.hex.halfRadius)));


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
							
							hexCenter.y = (hexCenter.y - hexBoard.hex.perpendicular);
						
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
                        hexBoard.selected.row = row;
                        hexBoard.selected.col = col;						
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


D3_Point[6] defineHexVertices(float x, float y, HexLengths hex)
{
    D3_Point[6] points;
	
	points[0].x = x + hex.halfRadius;
	points[0].y = y;	
	points[0].z = 0.0;		

	points[1].x = x + hex.halfRadius + hex.radius;
	points[1].y = y;
	points[1].z = 0.0;		

	points[2].x = x + hex.diameter;
	points[2].y = y + hex.apothem;
	points[2].z = 0.0;		

	points[3].x = x + hex.halfRadius + hex.radius;
	points[3].y = y + hex.perpendicular;
	points[3].z = 0.0;		

	points[4].x = x + hex.halfRadius;
	points[4].y = y + hex.perpendicular;
	points[4].z = 0.0;	

	points[5].x = x;
	points[5].y = y + hex.apothem;
	points[5].z = 0.0;	
	
    return points;
} 


D3_Color[6] defineHexColor(float x, float y, /+D3_Color color+/ float red)
{
    D3_Color[6] points;
	
	points[0].r = red;
	points[0].g = 0.0;	
	points[0].b = 0.0;		

	points[1].r = red;
	points[1].g = 0.0;	
	points[1].b = 0.0;		
		
	points[2].r = red;
	points[2].g = 0.0;	
	points[2].b = 0.0;		
	
	points[3].r = red;
	points[3].g = 0.0;	
	points[3].b = 0.0;		
	
	points[4].r = red;
	points[4].g = 0.0;	
	points[4].b = 0.0;		
	
	points[5].r = red;
	points[5].g = 0.0;	
	points[5].b = 0.0;		
	
    return points;
} 




D3_Point defineHexCenter(float x, float y, float apothem, float radius)
{
    D3_Point center;
	
	center.x = x + radius;
	center.y = y + apothem;
    center.z = 0.0;
	
    return center;
} 


D3_Point[4] defineSelectedSquare(float x, float y, HexLengths hex)
{
    D3_Point[4] points;
	float offset = (hex.apothem/2.0);
	
	points[0].x = x - offset;
	points[0].y = y - offset;	
	points[0].z = 0.0;	

	points[1].x = x + offset;
	points[1].y = y - offset;
	points[1].z = 0.0;		
		
	points[2].x = x + offset;
	points[2].y = y + offset;
	points[2].z = 0.0;		
	
	points[3].x = x - offset;
	points[3].y = y + offset;
	points[3].z = 0.0;	
	
    return points;
} 








void drawSelectedSquare()
{
    int tRow = hexBoard.selected.row;
    int tCol = hexBoard.selected.col;	

    if ((hexBoard.selected.row == invalid) || (hexBoard.selected.col == invalid))
        return;
		
    hexCenter = hexBoard.hexes[tRow][tCol].center;
			
    hexBoard.squarePts = defineSelectedSquare(hexCenter.x, hexCenter.y, hexBoard.hex);	
	
			
    selectedVertices.length = 0;  // delete contents of dynamic array
 
    foreach(p; 0..4)  // for each point
    {
        selectedVertices ~= hexBoard.squarePts[p].x;  
        selectedVertices ~= hexBoard.squarePts[p].y;
        selectedVertices ~= hexBoard.squarePts[p].z; 
    }
 
    glDeleteVertexArrays(1, &VAO2);      // the VAO2 may hold an old (previously selected) hex

    VAO2 = createSquareVAO(selectedVertices);
 
	glBindVertexArray(VAO2);  // Make the hexboard the active VAO

    /+		
    int k = 0;
    while (k < selectedVertices.length )
    {
        glDrawArrays(GL_LINE_LOOP, k, 4);
        k += 4;
    }
    +/
    glDrawArrays(GL_LINE_LOOP, 0, 4);
		
    return;	
}



void drawSolidHex(uint r, uint c, D3_Color color)
{
    //assert((r < rows) && (c < cols));
		
    D3_Point[6] hex = hexBoard.hexes[r][c].points;
		
    writeln("hex = ", hex);	
	
    D3_Color[] colors;		
    D3_Point[] triStrip;
		
    triStrip ~= hex[0];
    triStrip ~= hex[1];		
    triStrip ~= hex[2];	

    triStrip ~= hex[0];
    triStrip ~= hex[2];		
    triStrip ~= hex[5];	
	
    triStrip ~= hex[5];
    triStrip ~= hex[2];		
    triStrip ~= hex[3];

    triStrip ~= hex[5];
    triStrip ~= hex[3];		
    triStrip ~= hex[4];	
	
	
    solidVerts.length = 0;  // make sure array is empty
 
    foreach(pt; triStrip)  // for each point
    {
        solidVerts ~= pt.x;  
        solidVerts ~= pt.y;
        solidVerts ~= pt.z; 
    }
	
 
    foreach(i; 0..5)  // for each point
    {
        colorVerts ~= color;  
    }
			
    GLuint solidVOA = createSolidHexVAO(solidVerts, colorVerts);

    writeln("solidVOA = ", solidVOA);	
 
	glBindVertexArray(solidVOA);  // Make the hexboard the active VAO


    //glDrawArrays(GL_TRIANGLES, 0, 3); // works for 1 triangle
	//glDrawArrays(GL_TRIANGLES, 0, 6);  // works for 2 triangles
	glDrawArrays(GL_TRIANGLES, 0, 12);  // works for 4 triangles

    return;	
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

GLuint VBO, VBO2, VAO, VAO2;

// vertex data

float[] vertices = [ /+ Positions Colors +/ ];
float[] selectedVertices = [ /+ Positions +/ ];	
float[] solidVerts = [ /+ Positions +/ ];		
float[] colorVerts = [ /+ Colors +/ ];
	
void main(string[] argv)
{
    // diameter is a user defined constant in NDC units, so needs to be between [0.0, 2.0)
    // which because of the hex board stagger makes a row of 5 (not 4) hexes.
    // A diameter of 2.0, would display a single hex which would fill the full width 
    // of the window and 0.866 of the windows height.

    hexBoard.hex.diameter      = 0.77;  
								  
    hexBoard.hex.radius        = (hexBoard.hex.diameter * 0.5);	
    hexBoard.hex.halfRadius    = (hexBoard.hex.radius * 0.5);	
									
    hexBoard.hex.perpendicular = (hexBoard.hex.diameter * 0.866);	
    hexBoard.hex.apothem       = (hexBoard.hex.perpendicular * 0.5);
	
	hexBoard.selected.row = invalid;
    hexBoard.selected.col = invalid;

	hexBoard.edge.bottom = -1.0;

    // find the top by starting at the bottom, and adding number of (# hex rows * height of the hexes)  
	
    // Note: edge.top will cut off half of the hex tops for odd columns but this is better
    // than causing an array index out of bounds run time error.
	
    hexBoard.edge.top = hexBoard.edge.bottom + (hexBoard.rows * hexBoard.hex.perpendicular); 
	
	hexBoard.edge.left = -1.0;

    hexBoard.edge.right = hexBoard.edge.left + (hexBoard.cols * (hexBoard.hex.radius + hexBoard.hex.halfRadius)); 	
	
	
    load_GLFW_Library();

    load_openGL_Library();  

    // window must be square

    auto winMain = glfwCreateWindow(winWidth, winHeight, "01_03_01_hex_study_vao", null, null);

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

    // DEFINE HEX BOARD
 	
    // start at the bottom left corner of the window, drawing from left to right,
    // bottom to top using NDC (Normalized Device Coordinates) which range between -1.0, -1.0
	
    float x = hexBoard.edge.left;   
    float y = hexBoard.edge.bottom;

    auto rnd = Random(unpredictableSeed);

    foreach(row; 0..hexBoard.rows)
    {
        foreach(col; 0..hexBoard.cols)
        {	
            hexBoard.hexes[row][col].points = defineHexVertices(x, 
			                                                    y, 
																hexBoard.hex);
			
            hexBoard.hexes[row][col].center = defineHexCenter(x, 
			                                                  y, 
															  hexBoard.hex.apothem, 
															  hexBoard.hex.radius);														  
            // Generate a float in [0, 1]
            float b = uniform!"[]"(0.0f, 1.0f, rnd);  // assert(0 <= b && b <= 1);
            writeln("b = ", b);


            hexBoard.hexes[row][col].colors = defineHexColor(x, y, b /+1.0+/);
			
            if (col.isEven)
            {
                y += hexBoard.hex.apothem;
            }
            else
            {			
                y -= hexBoard.hex.apothem;   
            }
            x += hexBoard.hex.halfRadius + hexBoard.hex.radius;  
        }
		
        x = hexBoard.edge.left;  // start a new row and column
		
        if (hexBoard.cols.isOdd)
        {
            y -= hexBoard.hex.apothem;
        }
        		
        y += hexBoard.hex.perpendicular;	
    }  

    hexBoard.displayHexBoard();		



    // take an array of position data xyzxyzxyz... and color data rgbrgbrgb...
	// and interleave them into an array of xyzrgbxyzrgbxyzrgb...
	
    foreach(row; 0..hexBoard.rows)
    {
        foreach(col; 0..hexBoard.cols)
        {
            foreach(p; 0..6)  // each point consists of position data
            {
                vertices ~= hexBoard.hexes[row][col].points[p].x;  
                vertices ~= hexBoard.hexes[row][col].points[p].y;
                vertices ~= hexBoard.hexes[row][col].points[p].z;
                vertices ~= hexBoard.hexes[row][col].colors[p].r;  
                vertices ~= hexBoard.hexes[row][col].colors[p].g;
                vertices ~= hexBoard.hexes[row][col].colors[p].b;
            }	
        }
    }  	


    // Take the hexboard comprising a 2 dimensional array of hex objects and
	// convert it to a 1 dimensional (stream) array of vertices.

    /+
    foreach(row; 0..hexBoard.rows)
    {
        foreach(col; 0..hexBoard.cols)
        {
            foreach(p; 0..6)  // each point consists of position data
            {
                vertices ~= hexBoard.hexes[row][col].points[p].x;  
                vertices ~= hexBoard.hexes[row][col].points[p].y;
                vertices ~= hexBoard.hexes[row][col].points[p].z;
            }	
            foreach(p; 0..6)  // each point consists of color
            {
                vertices ~= hexBoard.hexes[row][col].colors[p].r;  
                vertices ~= hexBoard.hexes[row][col].colors[p].g;
                vertices ~= hexBoard.hexes[row][col].colors[p].b;
            }	

			
        }
    }  	
    +/    
 
    // feed the xyzrgbxyzrgb... into the function that makes the VAO 
	
    VAO = createHexBoardVAO(vertices);  // Called once

    glUseProgram(programID);

    // uncomment this call to draw in wireframe polygons.
    //glPolygonMode(GL_FRONT_AND_BACK, /+GL_LINE+/ GL_FILL);
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE_LOOP);	

    // enum pattern = defineVertexLayout!(int)([3,3]);
    // mixin(pattern);
    // pragma(msg, pattern);

    /+	
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * GLfloat.sizeof, cast(const(void)*) (0 * GLfloat.sizeof));
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * GLfloat.sizeof, cast(const(void)*) (3 * GLfloat.sizeof));
    glEnableVertexAttribArray(1);	
    +/
	
    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions  
        handleEvent(winMain);   

        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
		
        renderHexBoard(vertices, VAO);

        if ((hexBoard.selected.row != invalid) && (hexBoard.selected.col != invalid))
        {
            drawSelectedSquare();  // only draw selected square when a hex is valid
        }		

        drawSolidHex(1, 1);
 
        glfwSwapBuffers(winMain);   // OpenGL does not remember what you drew in the past after a glClear() or swapbuffers.		
    }

    glfwTerminate();   // Clear any resources allocated by GLFW
	
    return;
}







