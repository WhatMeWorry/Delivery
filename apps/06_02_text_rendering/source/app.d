
module app;

import common;

import std.math;    // cos
import std.stdio;   // writeln
import std.conv;    // to
import gl3n.linalg; // vec3 mat4

import derelict.util.loader;
import derelict.util.sharedlib;
import derelict.freetype.ft;
import derelict.openal.al;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;

float angle;
float distance = 3.0;

bool firstMouse = true;




extern(C) static void onInternalKeyEvent(GLFWwindow* window, int key, int scancode, int action, int modifier) nothrow
{
    if (key == GLFW_KEY_ESCAPE && action == GLFW_PRESS)
        glfwSetWindowShouldClose(window, GL_TRUE);
    if (key >= 0 && key < 1024)
    {
        if (action == GLFW_PRESS)
            keys[key] = true;
        else if (action == GLFW_RELEASE)
            keys[key] = false;
    }
}





extern(C) void onWindowResize(GLFWwindow* window, int width, int height) nothrow
{
    glfwSetWindowSize(window, width, height);   
    glViewport(0, 0, width, height);
}

 


// Window dimensions
enum width = 800;  enum height = 600;

GLfloat lastX =  width / 2.0;
GLfloat lastY =  height / 2.0;
bool[1024] keys;

// Light attributes
vec3 lightPos = vec3(1.2f, 1.0f, 2.0f);

// Deltatime
GLfloat deltaTime = 0.0f;	// Time between current frame and last frame
GLfloat lastFrame = 0.0f;  	// Time of last frame

Glyph[GLchar] courierBold;
Glyph[GLchar] phoenixRising;
Glyph[GLchar] eagleLake;
GLuint VAO, VBO;

// In D all classes are references
// This just declares a _pointer_ to Camera class that is set to null.  No Camera object is created.
Camera camera;  

// In D, all structs are value types.  This will actually create an object called textRenderSys
TextRenderingSystem textRenderSys;


void main(string[] argv)
{
    load_libraries();
	
    auto winMain = glfwCreateWindow(800, 600, "06_02_text_rendering", null, null);
	
    glfwMakeContextCurrent(winMain); 
	
    // you must set the callbacks after creating the window
	   
           glfwSetKeyCallback(winMain, &onInternalKeyEvent);
    glfwSetWindowSizeCallback(winMain, &onWindowResize);
	 
    // Define the viewport dimensions
    glViewport(0, 0, width, height);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	/+
    Shader[] shaders =
    [
        Shader(GL_VERTEX_SHADER,   "source/VertexShader.glsl",   0),
        Shader(GL_FRAGMENT_SHADER, "source/FragmentShader.glsl", 0)
    ];
    GLuint progID = createProgramFromShaders(shaders);	

    glUseProgram(progID);

               //mat4 orthographicFunc(left, right, bottom, top, near, far)
    mat4 projection = orthographicFunc(0.0, width, 0.0, height, -1.0, 1.0);

    //   (1) must be GL_FALSE
    //   (2) must be &projection[0][0]  or  cast(const(float)*) projection.ptr
    //                                                                  (1)            (2)
    glUniformMatrix4fv(glGetUniformLocation(progID, "projection"), 1, GL_FALSE, &projection[0][0]); //WORKS


    FT_Library library; 
    FT_Face courierBoldFont;   // Load font as face
	//FT_Face phoenixRisingFont;
    //FT_Face eagleLakeFont;     // Load font as face	
	
    initializeFreeTypeAndFace(library, courierBoldFont,   "../fonts/courbd.ttf");
    //initializeFreeTypeAndFace(library, phoenixRisingFont, "../fonts/phoenixrising.ttf");
    //initializeFreeTypeAndFace(library, eagleLakeFont,     "../fonts/EagleLake-Regular.ttf");

    initializeCharacters(courierBoldFont,   courierBold);
    //initializeCharacters(phoenixRisingFont, phoenixRising, 20);	
    //initializeCharacters(eagleLakeFont,     eagleLake);


    // Configure VAO/VBO for texture quads
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, GLfloat.sizeof * 6 * 4, null, GL_DYNAMIC_DRAW);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 4, GL_FLOAT, GL_FALSE, 4 * GLfloat.sizeof, cast(const(void)*) 0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
+/

    initTextRenderingSystem(textRenderSys);
	writeln("textRenderSys.progID = ", textRenderSys.progID);
	writeln("textRenderSys.VAO = ", textRenderSys.VAO);	
	writeln("textRenderSys.VBO = ", textRenderSys.VBO);	

    auto RED = vec3(1.0, 0.0, 0.0);
	
    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {     
        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions 

        // Clear the colorbuffer
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        renderText(textRenderSys.font, textRenderSys.VAO, textRenderSys.VBO, textRenderSys.progID, 
                   "This is sample Courier Bold text", 25.0f, 75.0f, 3.5f, vec3(0.0, 0.0f, 0.0f));

        // Play with scale value
        //renderText(courierBold, VAO, VBO, progID, "This changes scale to 0.5", 25.0f, 75.0f, 0.5f, vec3(0.5, 0.8f, 0.2f));

        //renderText(phoenixRising, VAO, VBO, progID, "Phoenix Rising  scale = 2.33", 25.0f, 150.0f, 2.33f, RED);

        //renderText(eagleLake, VAO, VBO, progID, "(C) Eagle Lake LearnOpenGL.com", 25.0f, 500.0f, 1.0f, vec3(0.8, 0.8f, 0.8f));

        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
	return;
}


