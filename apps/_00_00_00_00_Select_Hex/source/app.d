
module app;  // 00_00_00_00_Select_Hex

import dynamic_libs.glfw;



import std.stdio : writeln;

void main()
{

load_GLFW_Library();

auto winMain = glfwCreateWindow(800, 600, "glfw study", null, null);

glfwMakeContextCurrent(winMain); 

// must set the callbacks after creating the window

            glfwSetKeyCallback(winMain, &onKeyEvent);
glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);



// radius is the line (distance) from the hex center to any vertex
// apothem is distance from the hex center to the midpoint of any side.
//============================================================================
// ============ All calculations follow from these primary parameters ========
//============================================================================
double radius =  50;   // length of a line from hex center two anyone of its six points
int maxRows = 7;
int maxCols = 13;
//============================================================================

int maxGridCols = maxCols + 1;
int maxGridRows = maxRows * 2;

if (maxGridRows > 1)
{
    maxGridRows = maxGridRows + 1; 
}


// apothem - a line from the center of a regular polygon at right angles to any of its sides.
// radius - is the line (distance) from the center to any vertex of a regular polygon

double apothem = radius * 0.866;

//struct p = { x: radius, y: apothem}  // note: a hex is not symmetrically square

struct S { double x = radius; double y = apothem; } 
S p;

struct Point { double x; double y; }
Point pt;


double vertDiv      = radius * 1.5;
double oneFourth    = (radius * 2) / 4;
double sixEighths   = (radius * 2) * 0.75;
double threeFourths = sixEighths;
double oneEighths   = (radius * 2) / 8;

double hexHeight = 2 * (radius * 0.866);
double halfHexHeight = hexHeight / 2;

var selectedHex = 0;

double calculateCanvasWidth(int columns)
{
    double full = 0;
    double squeezed = 0;
    if (isEven(columns))
    {
        squeezed = (columns)/2;
        full = squeezed;
        return ((radius*2*full)+(radius*squeezed)+oneFourth);
    }
    else
    {
        squeezed = (columns-1)/2;
        full = squeezed + 1;
        return ((radius*2*full)+(radius*squeezed));
    }
}



double calculateCanvasHeight(int rows, int cols)
{
    if (cols > 1)
    {
         return ((rows * hexHeight) + halfHexHeight);
    }
    else
    {
         return (rows * hexHeight);   // rows should be always equal to 1
    }
}



void setup()
{
    //double canvasWidth = calculateCanvasWidth(maxCols);
    //double canvasHeight = calculateCanvasHeight(maxRows, maxCols);  
 
    //let canvas = createCanvas(canvasWidth, canvasHeight);

     
    //canvas.parent("ENTRY_SelectOneHex_js");   
   
    //canvas.mousePressed(handleMousePressed);  // attach listener  
 
    // hexBoard = [];
	
	Hex[maxRows][maxCols] hexBoard;

    double xDelta = radius * 1.5;
    double yDelta = 2 * (radius * 0.866);
    double offset = (radius * 0.866);
 
    for (int i = 0; i < maxRows; i++)     // for each row      
    {
        //hexBoard[i] = []; // create nested array
        p.x = radius;
        p.y = (i * yDelta) + offset;    
     
        for (j = 0; j <  maxCols; j++)     // for each column
        {   
            hexBoard[i][j] = hex(p, radius);
            p.x = p.x + xDelta;
     
            if (j % 2 == 0) {
                p.y = p.y + offset;
            } else {
                p.y = p.y - offset;            
            }                              
        }
    }
    //console.table(hexBoard);
    //noLoop();
}


bool isEven(int i)
{
    return (i % 2) == 0;
}



void draw()
{
    //background(220);
     
    for (int i = 0; i < hexBoard.length; i++)    // loop the outer array
    {
        int columnLen = hexBoard[i].length;      // radius of the inner array
     
        for (int j = 0; j < columnLen; j++)      // loop inner array
        {
            //console.log('[' + i + ',' + j + '] = ' + hexBoard[i][j]);
        }
    }
   
    // loop the outer array
    for (int i = 0; i < hexBoard.length; i++)
    {
        // get the radius of the inner array
        int columnLen = hexBoard[i].length;
     
        // loop the inner array
        for (int j = 0; j < columnLen; j++)
        {
            tempHex = hexBoard[i][j];
            tempHex.drawHex();
            //tempHex.displayCenter();
        }
    }

   
    for (int m = 0; m < maxCols+1; m++)
    {
        // draw vertical lines    
        //line((m*threeFourths),0, (m*threeFourths), canvasHeight);
     
        for (int n = 0; n < (maxRows*2)+1; n++)
        {
            // draw horizontal lines
            //line(0, (n*halfHexHeight), canvasWidth, (n*halfHexHeight));
        }          
    }

    for (int m = 0; m < maxCols+1; m++)
    {
        for (int n = 0; n < (maxRows*2)+1; n++)
        {
            //strokeWeight(2);
            if (isEven(m) && isEven(n))
            {
                //stroke(0,0,255);  
                //circle( (m * threeFourths) + threeFourths/2, (n * halfHexHeight) + halfHexHeight/2, 3);           
            }
            else if (!isEven(m) && isEven(n))
            {
                //stroke(255,0,0);  
                //circle( (m * threeFourths) + threeFourths/2, (n * halfHexHeight) + halfHexHeight/2, 3);           
            }  
            else if (isEven(m) && !isEven(n))
            {
                //stroke(0,255,0);  
                //circle( (m * threeFourths) + threeFourths/2, (n * halfHexHeight) + halfHexHeight/2, 3);           
            }                   
            else if (!isEven(m) && !isEven(n))
            {
                //stroke(255,255,0);  
                //circle( (m * threeFourths) + threeFourths/2, (n * halfHexHeight) + halfHexHeight/2, 3);             
            }            
        }          
    }  

}  

double getDistance(double x1, double y1, double x2, double y2)
{
    double y = x2 - x1;
    double x = y2 - y1;
   
    return Math.sqrt(x * x + y * y);
}


double convertGridRowToHexRow(int r)
{
    if (!isEven(r))
    {
        r = r - 1;  
    }
    return (r / 2);  
}


bool clickedInLowerLeftTriangle(mX, mY, x, y)
{
    double right = x - oneFourth;
    double adj = right - mX;
  
    // tan(60) = 1.7320
    // tan(theta) = opp / adj
             
    double opp = adj * 1.7320;     // This is the
             
    double bot = y + apothem;
    double tall = bot - mouseY;
             
    if (tall < opp)
    {
        return true;
    }
    return false;                      
}


function clickedInUpperLeftTriangle(mX, mY, x, y)
{
    double left = x - radius;
    double adj = mX - left;
  
    // tan(60) = 1.7320
    // tan(theta) = opp / adj
             
    double opp = adj * 1.7320;
             
    double bot = y;
    double tall = bot - mouseY;
             
    if (tall > opp)
    {
        return true;
    }
    return false;                      
}



// this function fires only when cnv is clicked
function handleMousePressed()
{
    //console.log("mouse (X, Y) = ", mouseX, mouseY);

    double gridCol = Math.floor(mouseX / threeFourths);
 
    double gridRow = Math.floor(mouseY / halfHexHeight);
 
    //    (even, even)  |  (even odd)
    //    -------------------------------
    //    (odd, even)   |  (odd, odd)
 
    // will need both square grid and hex grid coordinates

    var row = 0;  
    var col = 0;
 
    var centerX = 0;
    var centerY = 0;


    if (isEven(gridRow) && isEven(gridCol))   // DONE : Upper Left Quadrant
    {       
        // gridRow is always going to be even, so just divide by 2
        row = gridRow / 2;
        col = gridCol;
     
        // hex must either be hexBoard[row][col] or hexBoard[row-1][col-1] or out of bounds
 
        //console.log("(gridRow,gridCol) = (", gridRow, ',', gridCol, ')');  
        //console.log("(row,col) = (", row, ',', col, ')'); 
        //console.log("maxGridCols = ", maxGridCols);
        //console.log("maxCols = ", maxCols);
        //console.log("maxGridRows = ", maxGridRows);
      
        // Form B and C are the most degenerate because they a completely empty rectanles
      
        if ( isEven(maxCols) && (gridCol == maxGridCols-1) && (gridRow == 0))
        {
            console.log("FORM B");
            selectedHex = 0;
        }
      
        else if ( (maxCols >= 2) && 
                  (gridCol == 0) && 
                  (gridRow == maxGridRows-1) )
        {
            console.log("FORM C");
            selectedHex = 0;          
        } 
        else if ( (col == maxCols) ||   // along the right edge of hex board
                  ((gridRow == maxGridRows-1) && isEven(gridCol))  // or bottom edge
                )
        {  
            console.log("FORM D or FORM F");
            centerX = hexBoard[row-1][col-1].center.x + threeFourths;
            centerY = hexBoard[row-1][col-1].center.y + halfHexHeight;  

            if (clickedInUpperLeftTriangle(mouseX, mouseY, centerX, centerY))
            { 
                console.log("    Inside Hex");
                selectedHex = hexBoard[row-1][col-1];
            }
            else
            {
                console.log("    Outside Hex");
                selectedHex = 0;               
            }
        }
        else
        {     
            centerX = hexBoard[row][col].center.x;
            centerY = hexBoard[row][col].center.y;
          
            if (clickedInUpperLeftTriangle(mouseX, mouseY, centerX, centerY))
            { 
                if (row == 0 || col == 0)
                {
                    console.log("FORM A - Outside Hex");
                    selectedHex = 0;          
                }
                else
                {
                    console.log("FORM E - Inside Small Triangle");
                    selectedHex = hexBoard[row-1][col-1];
                }
            } 
            else
            {
                console.log("FORM A - Inside Hex");
                selectedHex = hexBoard[row][col];
            }  
        }
    }

  

    if (isEven(gridRow) && !isEven(gridCol))  // DONE : Upper Right Quadrant
    { 
        // gridRow is always going to be even, so just divide by 2
        row = (gridRow / 2) -1;
        col = gridCol;
      
        //console.log("(gridRow,gridCol) = (", gridRow, ',', gridCol, ')');  
        //console.log("(row,col) = (", row, ',', col, ')'); 
        //console.log("maxGridCols = ", maxGridCols);
        //console.log("maxCols = ", maxCols);
        //console.log("maxGridRows = ", maxGridRows);
      
        if ((gridRow == maxGridRows-1) && (gridCol == maxGridCols-1))
        {     
            console.log("FORM E"); 
            selectedHex = 0;        
        }
        else if ((row == -1) || (col == maxCols))
        {
            console.log("FORM A or D   Top or Right Edge");
            centerX = hexBoard[row+1][col-1].center.x + threeFourths;
            centerY = hexBoard[row+1][col-1].center.y - halfHexHeight; 
            if (clickedInLowerLeftTriangle(mouseX, mouseY, centerX, centerY))
            {
                selectedHex = hexBoard[row+1][col-1];
            }
            else
            {
                 console.log("OUTSIDE OF HEX"); 
                 selectedHex = 0;
            }        
        }     
        else
        {
            console.log("FORM B or C");
            centerX = hexBoard[row][col].center.x;
            centerY = hexBoard[row][col].center.y; 
            if (clickedInLowerLeftTriangle(mouseX, mouseY, centerX, centerY))
            {            
                if (row == maxRows-1)
                {
                    console.log("FORM C outside bottom hex"); 
                    selectedHex = 0;     
                }
                else
                {
                    console.log("FORM B");
                    selectedHex = hexBoard[row+1][col-1];
                }
            }
            else
            {
                console.log("FORM B within main hex");
                selectedHex = hexBoard[row][col]; 
            }          
        }
    }
  
  

    if (!isEven(gridRow) && isEven(gridCol))  // DONE : Lower Left Quadrant
    {
        // gridRow is always going to be odd, so
        row = (gridRow - 1) / 2;
        col = gridCol;
 
        //console.log("(gridRow,gridCol) = (", gridRow, ',', gridCol, ')');  
        //console.log("(row,col) = (", row, ',', col, ')'); 
        //console.log("maxGridCols = ", maxGridCols);
        //console.log("maxCols = ", maxCols);
        //console.log("maxGridRows = ", maxGridRows);      
      
 
        if (col == 0)
        {
            console.log("FORM A");  // along left edge of hex board          
            centerX = hexBoard[row][col].center.x;
            centerY = hexBoard[row][col].center.y;          
          
            if (!clickedInLowerLeftTriangle(mouseX, mouseY, centerX, centerY))
            {
                selectedHex = hexBoard[row][col];
                console.log("  Inside Hex");
            }
            else
            {
                selectedHex = 0;
                console.log("  Outsied hex board");                 
            }            
        }
        else if (gridCol == maxGridCols-1)    // along right edge of hex board  
        {
            console.log("FORM C");           
            centerX = hexBoard[row][col-1].center.x + threeFourths;
            centerY = hexBoard[row][col-1].center.y - halfHexHeight;
          
            if ( clickedInLowerLeftTriangle(mouseX, mouseY, centerX, centerY) )
            {      
                selectedHex = hexBoard[row][col-1];
                console.log("   Inside Small Tria"); 
            }
            else
            {  
                console.log("   Outside of hex board");
                selectedHex = 0;
            }                              
        }
        else                     // middle of hex board
        {         
            console.log("FORM B");
          
            centerX = hexBoard[row][col].center.x;
            centerY = hexBoard[row][col].center.y; 
          
            if ( clickedInLowerLeftTriangle(mouseX, mouseY, centerX, centerY) )
            {      
                selectedHex = hexBoard[row][col-1];
                console.log("   Inside small triangle"); 
            }
            else
            {  
                selectedHex = hexBoard[row][col];
                console.log("   Inside main hex");
            }                              
        }
    }



    if (!isEven(gridRow) && !isEven(gridCol))
    {
        // gridRow is always going to be odd, so
        row = (gridRow - 1) / 2;
        col = gridCol;
 
        //console.log("(gridRow,gridCol) = (", gridRow, ',', gridCol, ')');  
        //console.log("(row,col) = (", row, ',', col, ')');                     
      
        // hex must either be hexBoard[row][col] or [row][col-1]
        if (col < maxCols)
        {  
            
            centerX = hexBoard[row][col].center.x;
            centerY = hexBoard[row][col].center.y;
        }
        else
        {   
            centerX = hexBoard[row][col-1].center.x + threeFourths;
            centerY = hexBoard[row][col-1].center.y + halfHexHeight          
        }
      
        if (clickedInUpperLeftTriangle(mouseX, mouseY, centerX, centerY))
        { 
            selectedHex = hexBoard[row][col-1];
            console.log("FORM A - Small Triangle");
        }
        else
        {
            if (col < maxCols)
            {
                selectedHex = hexBoard[row][col];
                console.log("FORM A - Large Polygon ");
            }
            else
            {
                console.log("TOO FAR RIGHT");
                selectedHex = 0;
                console.log("FORM B - Outside hex board ");
            }
        }
    }    



    draw();  // redraw the hex board mainly to clear any circles

    if (selectedHex != 0)
    {
        selectedHex.drawCircle(); 
    }

    // tHex.drawCircle();
 
 

/*
    if (candidates.length == 2)
    {
        // find the hex that is closest to the mouse click
        var len0 = getDistance(candidates[0].center.x,   candidates[0].center.y,   mouseX, mouseY);
        var len1 = getDistance(candidates[1].center.x,   candidates[1].center.y,   mouseX, mouseY);
        if (len0 < len1)
        {
            // Starting at index position 1, remove 1 element (len1)
            candidates.splice(1,1);
        }  
        else
        {
            candidates.splice(0,1);    // len1 is the shortest distance from the mouse click.
        }
    }
    console.log("candidates.length = ", candidates.length);  
    for (i = 0; i < candidates.length; i++) {
        tempHex =  candidates[i];
        //tempHex.drawCircle();
        candidates[i].drawCircle();
    }
*/
  

 
}
 
 
 
 




//class hex
struct Hex
{
    double one, two, three, four, five, size;
	int r, g, b;
	struct center { double x; double y; }
	
    //constructor(p, radius)
    this(struct S p, double radius)
    {

        //  farLeft = p.x - radius;
        //     left = p.x - (radius/2);
        //    right = p.x + (radius/2);
        // farRight = p.x + radius;
     
        //    top = p.y + (radius * 0.866);
        // middle = p.y;
        // bottom = p.y - (radius * 0.866);
 
        //this.center = { x: p.x, y: p.y}
		center.x = p.x;
		center.y = p.y;
		
     
        //this.r = 150;  this.g = 150;  this.b = 150;
        r = 150;
		g = 150;
		b = 150;
     
        // screens coordinates are flipped horizontally from cartesion coordinates
        //this.one   = {x: p.x+radius,     y: p.y}
        //this.two   = {x: p.x+(radius/2), y: p.y+(radius*0.866)}
        //this.three = {x: p.x-(radius/2), y: p.y+(radius*0.866)}
        //this.four  = {x: p.x-radius,     y: p.y}
        //this.five  = {x: p.x-(radius/2), y: p.y-(radius*0.866)}
        //this.six   = {x: p.x+(radius/2), y: p.y-(radius*0.866)}
		
        this.one   = {x: p.x+radius,     y: p.y}
        this.two   = {x: p.x+(radius/2), y: p.y+(radius*0.866)}
        this.three = {x: p.x-(radius/2), y: p.y+(radius*0.866)}
        this.four  = {x: p.x-radius,     y: p.y}
        this.five  = {x: p.x-(radius/2), y: p.y-(radius*0.866)}
        this.six   = {x: p.x+(radius/2), y: p.y-(radius*0.866)}
    }

    setColor()
    {
        //console.log("color = ", this.r, this.g, this.b);
        this.r = 255;
        this.g = 0;
        this.b = 0;
    }
 
    displayCenter()
    {
        console.log("this.center.x = ", this.center.x);
        console.log("this.center.y = ", this.center.y);      
    }
 
    drawCircle()
    {  
        // R, G & B integer values
        //stroke(255,0,0);  
        //strokeWeight(2);
     
        circle(this.center.x, this.center.y, offset*2);    
    }  
 
 
    drawHex()
    {  
        // R, G & B integer values
        stroke(0,0,0);    
        strokeWeight(2);
     
     // circle(this.center.x, this.center.y, offset*2);    
        beginShape();
        //fill(random(0, 255), random(0, 255), random(0, 255));
        fill(this.r, this.g, this.b);      
        vertex(this.one.x, this.one.y);
        vertex(this.two.x, this.two.y);
        vertex(this.three.x, this.three.y);
        vertex(this.four.x, this.four.y);
        vertex(this.five.x, this.five.y);
        vertex(this.six.x, this.six.y);
        endShape(CLOSE);
     
    }
}
	
	
	
	
	
	
}
