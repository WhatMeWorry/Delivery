
module app;  // 01_03_02_hex_resize 
import shaders; 
import texturefuncs;
import mytoolbox;
import derelict_libraries;
import event_handler;
import common; // freetypefuncs.d - orthographicFunc()
import common_game;
import std.stdio;  // writeln
import std.conv;   // toChars
import derelict.util.loader;
import derelict.util.sharedlib;
import derelict.freetype.ft;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import gl3n.linalg; // mat3

GLfloat[] board;

GLfloat[] NDCsquare;  // Normalized Device Coordinates

// start at the bottom left corner of the NDC
GLfloat x = -1.0;
GLfloat y = -1.0;
GLfloat startX = -1.0;   // NDC Normalized Device Coordinates start at -1.0 and ends at 1.0 for all axes
GLfloat startY = -1.0;   // the board will be drawn starting from the lower left corner of screen
 
struct Delta
{
    GLfloat rise;
    GLfloat run;
}

Delta delta;

GLfloat halfRun;
GLfloat quarRun;
GLfloat halfRise;

/+
How does one convert pixel length (i.e an image with 512 pixel width and height) to accurate 
OpenGL coordinates?

All I can do now is try to guess the size manually between -1 and 1.

=============================================================================================

The question is quite vague, but as I see it the problem is that the window coordinates are 
ranging, as you say, between -1 to 1; and since the screen is a rectangle, quads will be 
drawn as a rectangle rather than a square.  It is not recommended to draw in "pixel coordinates" 
since all monitors don't have the same resolution nor the same aspect ratio. However, if your 
are certain that this is what you want to do, then this is how you'd do it:

=============================================================================================

If you are using shaders with OpenGL 3+:

    Just divide the x coordinate by half of the width of the window and subtract 1.
    Do the same for the the y coordinate but divide by half the height instead of half the width.

If you are using the old immediate mode OpenGL (which by the way is not recommended and outdated 
since long ago) then you should look into glOrtho
Note that all the above is just for orthographic projection (2D).

If you want to draw in 3D you should not draw in "pixel coordinates" by any means. Instead, 
multiply either the width or height by the relevant aspect ratio (i.e width/height or height/width)
or integrate the aspect ratio into your perspective projection if creating your own shader.

Generally, OpenGL does not draw by pixels. You draw into OpenGL's own coordinate system and 
OpenGL will then convert it to pixels. This is what makes it so powerful for 3D rendering. 
This approach is much more convenient because of the differing monitor resolutions and aspect 
ratios.

=============================================================================================

If you want to address pixels precisely, the previously posted answer is not sufficient. It 
calculates the lower left corner of pixels. But to place a vertex exactly on a pixel, you need 
to use the coordinates of the pixel center.

In your example with a width of 512 pixels, without any transformations applied, these pixels 
span the NDC coordinate range of [-1.0, 1.0]. This means that the width of each pixel is 2.0 / 512 
in NDC space.

For example, for the very first pixel, if you look at it as a small square, its coordinate range 
is from -1.0 to -1.0 + 2.0 / 512. It's center is therefore at -1.0 + 1.0 / 512 in NDC space.

Generalizing this for a general window width w and height h, the coordinates of pixel with 
index i in horizontal direction and index k in vertical direction (bottom to top) are:

x = -1.0 + i * (2.0 / w) + (1.0 / w) = (2.0 * i + 1.0) / w - 1.0
y = -1.0 + k * (2.0 / h) + (1.0 / h) = (2.0 * k + 1.0) / h - 1.0

if width 
+/

// The problem with using Normalized Device Coordinates (NDC) is that when a window is not
// square, the x, y values are not propotional. So on rectangular windows (1,1) (-1,-1) will not
// form a square (in other words, not have equal pixels on their sides)
// Pixel coordinates are however proportional. So (0,0) - (640, 640) will form a square

//===========================================================================================

/+
 Jamie King   https://www.youtube.com/watch?v=A8uSL7JBsBs&index=125&list=PLRwVmtr-pp04XomGtm-abzb-2M1xszjFx&t=0s

aspectRatio = width / height


http://duriansoftware.com/joe/An-intro-to-modern-OpenGL.-Chapter-3:-3D-transformation-and-projection.html

mat3 window_scale = mat3(
        vec3(3.0/4.0, 0.0, 0.0),
        vec3(    0.0, 1.0, 0.0),
        vec3(    0.0, 0.0, 1.0)
    );


+/

void drawHexagon(GLfloat x, GLfloat y, Delta delta, GLfloat halfRise, GLfloat quarRun, GLfloat halfRun)
{
    // initialize each hexagon 
    board ~= [x + quarRun,           y,              0.0];
    board ~= [x + quarRun + halfRun, y,              0.0];
    board ~= [x + delta.run,         y + halfRise,   0.0];
    board ~= [x + quarRun + halfRun, y + delta.rise, 0.0]; 
    board ~= [x + quarRun,           y + delta.rise, 0.0];
    board ~= [x,                     y + halfRise,   0.0];                       
}

void drawNDCsquare()
{   
    NDCsquare ~= [-.995,  .995, 0.0];
    NDCsquare ~= [-.995, -.995, 0.0];
    NDCsquare ~= [ .995, -.995, 0.0];
    NDCsquare ~= [ .995,  .995, 0.0];                   
}

void drawHexBoard()
{
    bool stagger = false; 

    while(y < 1.0)   // outside NDC of 1.0
    {
        GLfloat tempY = y;
        while(x < 1.0)  // outside NDC of 1.0
        {
            drawHexagon(x, tempY, delta, halfRise, quarRun, halfRun);
            stagger = !stagger;

            if (stagger)
                tempY += halfRise;
            else 
                tempY -= halfRise;   

            x += quarRun + halfRun;  
        }
        x = startX;       
        y += delta.rise;
    }  
}

void setHexParameters()
{
    delta.run = howWide;
    delta.rise = delta.run * 0.866;  // hex is only .866 as tall as a unit 1.0 equilateral hex is wide

    halfRun  = delta.run  * 0.5;
    quarRun  = delta.run  * 0.25;
    halfRise = delta.rise / 2.0;

    writeln("halfRun = ", halfRun);
    writeln("quarRun = ", quarRun);
    writeln("halfRise = ", halfRise);  

    writeln("delta.run = ", delta.run);
    writeln("delta.rise  = ", delta.rise);    
}


void do_movement(Event event)
{
    GLfloat magnify = 1.00;
    writeln("Inside do_movement");    
    if (event.keyboard.key == Key.w)
        camera.ProcessKeyboard(Camera_Movement.FORWARD, (deltaTime * magnify));
    if (event.keyboard.key == Key.s)
        camera.ProcessKeyboard(Camera_Movement.BACKWARD, (deltaTime * magnify));
    if (event.keyboard.key == Key.a)
        camera.ProcessKeyboard(Camera_Movement.LEFT, (deltaTime * magnify));
    if (event.keyboard.key == Key.d)
        camera.ProcessKeyboard(Camera_Movement.RIGHT, (deltaTime * magnify));   
}

const GLfloat howWide = .50;  // .50 is an arbitrary constant, a fraction of 
                              // the range [-1.0, 1.0] or distance 2.0   So .5 should give you 4 hex wide.

Camera camera;
// Deltatime
GLfloat deltaTime = 0.01f;  // Time between current frame and last frame

void main(string[] argv)
{
    camera = new Camera(vec3(0.0f, 0.0f, 3.0f));
    writeln("after new Camera");
    
    // Window dimensions
    //int width = 1200;  int height = 600;  // works
    //int width = 833;  int height = 431;  // works
    int width = 1600;  int height = 777;

    GLfloat aspectRatio = cast(float) width / cast(float) height;

    //mat4 projection = orthographicFunc(0.0, width, 0.0, height, -1.0f, 1.0f);
    mat4 projection = mat4.identity;  

    //projection = orthographicFunc(0.0, width, height, 0.0, -1.0f, 1.0f);
    //projection = orthographicFunc(-1.0, 1.0,   1.0, -1.0, 1.0,  10.0);
    projection = orthographicFunc(-aspectRatio, aspectRatio, 1.0, -1.0, 1.0, 10.0);   

    mat4 view = camera.GetViewMatrixFixedAhead();  // not sure if I like the view being dependent on the camera class?
                                         // maybe refactor this?
    writeln("view matrix = ", view);

    //GLfloat aspectRatio = cast(float) width / cast(float) height;

    //GLfloat reciprocalWindowScale = 1.0 / aspectRatio;

    setHexParameters();

    load_libraries();

    // window must be square

    auto winMain = glfwCreateWindow(width, height, "01_03_02_hex_resize", null, null);

    glfwMakeContextCurrent(winMain); 
   // you must set the callbacks after creating the window
 
            glfwSetKeyCallback(winMain, &onKeyEvent);
      glfwSetCursorPosCallback(winMain, &onCursorPosition);
     //glfwSetWindowSizeCallback(winMain, &onWindowResize);
glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);
    glfwSetCursorEnterCallback(winMain, &onCursorEnterLeave);  // triggered when cursor enters or leaves the window

    showAllMonitors();
    showMonitorVideoMode();

    // glgetInteger.. queries must be done AFTER opengl context is created!!!

    GLint[2] maxViewportDims;
    glGetIntegerv(GL_MAX_VIEWPORT_DIMS, maxViewportDims.ptr);
    writeln("maxViewportDims = ", maxViewportDims);

    GLint maxRenderBufferSize;
    glGetIntegerv(GL_MAX_RENDERBUFFER_SIZE_EXT, &maxRenderBufferSize); 
    writeln("maxRenderBufferSize = ", maxRenderBufferSize);

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

    drawHexBoard();
    drawNDCsquare();

    vertices = board;

    GLuint VBO, VBO1, VAO, VAO1;
    glGenVertexArrays(1, &VAO);
   glGenVertexArrays(1, &VAO1);    
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &VBO1);

    // bind the Vertex Array Object first, then bind and set vertex buffer(s), and then configure vertex attributes(s).
    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.bytes, vertices.ptr, GL_STATIC_DRAW);

    enum describeBuff = defineVertexLayout!(int)([3]);
    mixin(describeBuff);
    pragma(msg, describeBuff);

    glBindVertexArray(VAO1);

    glBindBuffer(GL_ARRAY_BUFFER, VBO1);
    glBufferData(GL_ARRAY_BUFFER, NDCsquare.bytes, NDCsquare.ptr, GL_STATIC_DRAW);

    enum describeBuff1 = defineVertexLayout!(int)([3]);
    mixin(describeBuff1);
    pragma(msg, describeBuff1);

    // Position attribute
    //glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * GLfloat.sizeof, cast(const(void)*) 0);
    //glEnableVertexAttribArray(0);

    //GLint reciprocalWindowScaleLoc = glGetUniformLocation(programID, "reciprocalWindowScale");

    //glUniform1f(reciprocalWindowScaleLoc, reciprocalWindowScale);  

    GLint projLoc = glGetUniformLocation(programID, "projection");
    glUniformMatrix4fv(projLoc,  1, GL_FALSE, projection.value_ptr);
    //writeln("projection = ", projection);

    GLint viewLoc = glGetUniformLocation(programID, "view");
    glUniformMatrix4fv(viewLoc,  1, GL_TRUE, view.value_ptr);
    //writeln("view = ", view);    

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
        //handleEvent(winMain); 

        Event event;   
        if (getNextEvent(winMain, event))
        {
            if (event.type == EventType.keyboard)
            {
                if (event.keyboard.key == Key.escape)
                    glfwSetWindowShouldClose(winMain, GLFW_TRUE);
                else
                    do_movement(event);
                    //moveCamera(event);
            }
            if (event.type == EventType.frameBufferSize)   // was handled in handleEvent(winMain)
                glViewport(0, 0, event.frameBufferSize.width, event.frameBufferSize.height);
            if (event.type == EventType.cursorInOrOut)
            {
                //enableCursor(event);
            }
            if (event.type == EventType.cursorPosition)
            {
                //processMouse(event.cursor.position.x, event.cursor.position.y);
            }
        }  

        int newWidth, newHeight;
        glfwGetWindowSize(winMain, &newWidth, &newHeight);  

        if ((width != newWidth) || (height != newHeight))  
        {
            writeln("Window changed size"); 
            writeln("newWidth = ", newWidth);
            writeln("newHeight = ", newHeight);            

            // THIS WORK! FREEZE THIS PROJECT

            if (newWidth >= newHeight)
            {
                aspectRatio = cast(float) newWidth / cast(float) newHeight;
                projection = orthographicFunc(-aspectRatio, aspectRatio, 1.0, -1.0, 1.0, 10.0); 
            }                
            else
            {
                aspectRatio = cast(float) newHeight / cast(float) newWidth;  
                projection = orthographicFunc(-1.0, 1.0, aspectRatio, -aspectRatio, 1.0, 10.0);
            }             
            writeln("aspectRatio = ", aspectRatio);
            width = newWidth;
            height = newHeight;

             
            glUniformMatrix4fv(projLoc,  1, GL_FALSE, projection.value_ptr);
            //reciprocalWindowScale = 1.0 / aspectRatio;
            //writeln("reciprocalWindowScale = ", reciprocalWindowScale);
 
            //glUniform1f(reciprocalWindowScaleLoc, reciprocalWindowScale); 
        }  

        //GLint viewLoc = glGetUniformLocation(programID, "view");
        view = camera.GetViewMatrixFixedAhead(); 

        //view = mat4.identity;       
        glUniformMatrix4fv(viewLoc,  1, GL_TRUE, view.value_ptr);
        //writeln("view = ", view);    

        // Clear the colorbuffer
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        glBindVertexArray(VAO);  // seeing as we only have a single VAO there's no need to bind it every time, 
		                         // but we'll do so to keep things a bit more organized
   
        glBindBuffer(GL_ARRAY_BUFFER, VBO);

        int i = 0;
        while (i < vertices.length)
        {
            glDrawArrays(GL_LINE_LOOP, i, 6);
            i += 6;
        }

        glBindVertexArray(VAO1);

        glBindBuffer(GL_ARRAY_BUFFER, VBO1);
        glDrawArrays(GL_LINE_LOOP, 0, 4);

        // glBindVertexArray(0); // no need to unbind it every time 
 
        glfwSwapBuffers(winMain);
    }



    glfwTerminate();   // Clear any resources allocated by GLFW.
    return;
}



