
module app;  // 04_01_depth_testing

import std.stdio : writeln; 
import std.math : PI;

import shaders;         // without - Error: undefined identifier Shader, createProgramFromShaders, ...
import event_handler;   // without - Error: undefined identifier onKeyEvent, onFrameBufferResize, handleEvent
import mytoolbox;       // without - Error: no property bytes for type float[]
import cameraModule;    // withoug - Error: undefined identifier Camera
import projectionfuncs; // without - Error: undefined identifier orthographicFunc 
import monitor;         // without - Error: undefined identifier showAllMonitors, showMonitorVideoMode
import texturefuncs;    // without - Error: undefined identifier loadTexture
import vertex_data;     // without - Error: undefined identifier initializeCube, initializeCubePositions
import timer;           // without - Error:  undefined identifier ManualTimer, AutoRestartTimer
import model;           // without - Error:  undefined identifier model

import dynamic_libs.glfw;       // without - Error: undefined identifier load_GLFW_Library, glfwCreateWindow
import dynamic_libs.opengl;     // without - Error: undefined identifier load_openGL_Library
import dynamic_libs.freeimage;  // without - Error: undefined identifier load_FreeImage_Library
import dynamic_libs.assimp;

import gl3n.linalg : vec3, mat4;


// Window dimensions
enum width = 1280;  enum height = 720;

Camera camera;  // C++ had: Camera  camera(glm::vec3(0.0f, 0.0f, 3.0f)); here
GLfloat lastX =  width / 2.0;
GLfloat lastY =  height / 2.0;

bool firstMouse = true;

// timing
GLfloat deltaTime = 0.0;
GLfloat lastFrame = 0.0;
GLfloat currentFrame = 0.0;

GLfloat movementSpeed = 2.5;

vec3 Front = vec3(0.0, 0.0, -1.0);
vec3 Position = vec3(0.0, 0.0, 0.0);
vec3 Right;

enum Movement 
{
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT
};

pragma(msg, "LINE 45");

void ProcessKeyboard2018_02_15(Movement direction, float deltaTime) nothrow
{
    float velocity = movementSpeed * deltaTime;
    //writeln("velocity = ", velocity);
    if (direction == Movement.FORWARD)
        Position += Front * velocity;
    if (direction == Movement.BACKWARD)
        Position -= Front * velocity;
    if (direction == Movement.LEFT)
        Position -= Right * velocity;
    if (direction == Movement.RIGHT)
        Position += Right * velocity;
}

extern(C) static void onInternalKeyEvent(GLFWwindow* window, int key, int scancode, int action, int modifier) nothrow
//void onKeyEvent(GLFWwindow *window)
{
    //writeAndPausewriteAndPause("Inside processInput2018_02_15");
    if (glfwGetKey(window, GLFW_KEY_ESCAPE) == GLFW_PRESS)
        glfwSetWindowShouldClose(window, true);

    if (glfwGetKey(window, GLFW_KEY_W) == GLFW_PRESS)
    {
        //writeln("key W was priced");
        ProcessKeyboard2018_02_15(Movement.FORWARD, deltaTime);   
    } 
    if (glfwGetKey(window, GLFW_KEY_S) == GLFW_PRESS)
    {
        //writeln("key S was priced");
        ProcessKeyboard2018_02_15(Movement.BACKWARD, deltaTime);
    } 
    if (glfwGetKey(window, GLFW_KEY_A) == GLFW_PRESS)
        ProcessKeyboard2018_02_15(Movement.LEFT, deltaTime);
    if (glfwGetKey(window, GLFW_KEY_D) == GLFW_PRESS)
        ProcessKeyboard2018_02_15(Movement.RIGHT, deltaTime);
}


pragma(msg, "LINE 85");

void main(string[] argv)
{
    pragma(msg, "After main");
    // Camera
    camera = new Camera(vec3(0.0, 0.0, 3.0));

    load_GLFW_Library();

    load_openGL_Library(); 

    load_FreeImage_Library();

    load_Assimp_Library();
   
    auto winMain = glfwCreateWindow(800, 600, "04_01_depth_testing", null, null);

    glfwMakeContextCurrent(winMain); 
 
    // you must set the callbacks after creating the window
    pragma(msg, "LINE 99");
 
                glfwSetKeyCallback(winMain, &onInternalKeyEvent);
          glfwSetCursorPosCallback(winMain, &onCursorPosition);
    //     glfwSetWindowSizeCallback(winMain, &onWindowResize);
    glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);
        glfwSetCursorEnterCallback(winMain, &onCursorEnterLeave);  // triggered when cursor enters or leaves the window
		
    // tell GLFW to capture our mouse
	
    glfwSetInputMode(winMain, GLFW_CURSOR, GLFW_CURSOR_DISABLED);

    // configure global opengl state

    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_ALWAYS); // always pass the depth test (same effect as glDisable(GL_DEPTH_TEST))

    // build and compile shaders

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

    pragma(msg, "compiling...");

    // Set up vertex data (and buffer(s)) and attribute pointers
    GLfloat[] cubeVertices;
    initializeCube(cubeVertices);

    // World space positions of our plane
    GLfloat[] planeVertices;
    initializePlane(planeVertices);

    // cube VAO
    GLuint cubeVAO, cubeVBO;
    glGenVertexArrays(1, &cubeVAO);
    glGenBuffers(1, &cubeVBO);
	
    glBindVertexArray(cubeVAO);
	
    glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
    glBufferData(GL_ARRAY_BUFFER, cubeVertices.bytes, cubeVertices.ptr, GL_STATIC_DRAW);

    enum patternCube = defineVertexLayout!(int)([3,2]);
    mixin(patternCube);
    pragma(msg, patternCube);

    glBindVertexArray(0);
	
    // plane VAO
    GLuint planeVAO, planeVBO;
    glGenVertexArrays(1, &planeVAO);
    glGenBuffers(1, &planeVBO);
	
    glBindVertexArray(planeVAO);
	
    glBindBuffer(GL_ARRAY_BUFFER, planeVBO);
    glBufferData(GL_ARRAY_BUFFER, planeVertices.bytes, planeVertices.ptr, GL_STATIC_DRAW);
	
    enum patternPlane = defineVertexLayout!(int)([3,2]);
    mixin(patternPlane);
    pragma(msg, patternPlane);
	
    glBindVertexArray(0);
	
    // Load and create a texture 
    GLuint cubeTexture;
    GLuint floorTexture;

    GLuint texture1;

    loadTexture(cubeTexture, "../art/marble.jpg");
    loadTexture(floorTexture, "../art/metal.png");

    
    // shader.setInt("texture1", 0); is ...
    // glUniform1i(    glGetUniformLocation(ID, name.c_str())    , value); 

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glUniform1i(glGetUniformLocation(programID, "texture1"), 0);
    
	
    // Get their uniform location
    GLint modelLoc = glGetUniformLocation(programID, "model");
    GLint viewLoc  = glGetUniformLocation(programID, "view");
    GLint projLoc  = glGetUniformLocation(programID, "projection");	

    while(!glfwWindowShouldClose(winMain))
    {
        // per-frame time logic
        //writeln("currentFrame = ", currentFrame);
        //writeAndPause("  ");
        currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;

        //processInput(winMain);
        
        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions  
        //handleEvent(winMain);   

        // render

        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Create transformations

        mat4 model      = mat4.identity;
        mat4 view       = mat4.identity;
        mat4 projection = mat4.identity;

        view = view.translate(vec3(0.0f, 0.0f, -3.0f));

        writeOnce!(view)();
        float degrees = 45.0;
        float fovRadians = (degrees * PI / 180.0);
        mat4 myProjection = mat4.identity;
		
        //glm::mat4 view = camera.GetViewMatrix();
        view = camera.GetViewMatrix();		
		
        // glm::mat4 projection = glm::perspective(glm::radians(camera.Zoom), (float)SCR_WIDTH/(float)SCR_HEIGHT, 0.1f, 100.0f);
        projection = perspectiveFunc(fovRadians, width/height, 0.1, 100.0);	
		
        // setMat4() is...
        // glUniformMatrix4fv(   glGetUniformLocation(ID, name.c_str())     , 1, GL_FALSE, &mat[0][0]);		
		
        //shader.setMat4("view", view);
        glUniformMatrix4fv(viewLoc, 1, GL_TRUE, view.value_ptr);
        //shader.setMat4("projection", projection);	
	    glUniformMatrix4fv(projLoc, 1, GL_FALSE, projection.value_ptr);

	    // cubes
        glBindVertexArray(cubeVAO);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, cubeTexture);
		
        //model = glm::translate(model, glm::vec3(-1.0f, 0.0f, -1.0f));
        model = mat4.identity;
        model = model.translate(vec3(-1.0, 0.0, -1.0));	

        //shader.setMat4("model", model);
        glUniformMatrix4fv(modelLoc, 1, GL_TRUE, model.value_ptr);		
        glDrawArrays(GL_TRIANGLES, 0, 36);
		
        model = mat4.identity;
        model = model.translate(vec3(2.0, 0.0, 0.0));
        //shader.setMat4("model", model);
        glUniformMatrix4fv(modelLoc, 1, GL_TRUE, model.value_ptr);				
        glDrawArrays(GL_TRIANGLES, 0, 36);
		
		
        // floor
        glBindVertexArray(planeVAO);
        glBindTexture(GL_TEXTURE_2D, floorTexture);
        //shader.setMat4("model", glm::mat4());
		model = mat4.identity;
        glUniformMatrix4fv(modelLoc, 1, GL_TRUE, model.value_ptr);				
        glDrawArrays(GL_TRIANGLES, 0, 6);
        glBindVertexArray(0);
		
        glfwSwapBuffers(winMain);
        glfwPollEvents();
    }
	
    // deallocate all resources because no longer needed

    glDeleteVertexArrays(1, &cubeVAO);
    glDeleteVertexArrays(1, &planeVAO);
    glDeleteBuffers(1, &cubeVBO);
    glDeleteBuffers(1, &planeVBO);

    glfwTerminate();
	
}	
	
	
	
	
	
	
	
	
	
	
	




	