
module app;    // 02_01_lighting_colors

import common;

import gl3n.linalg; // vec3
import std.math;    //  sin cose
import std.stdio;   // writeln

import derelict.util.loader;
import derelict.util.sharedlib;
import derelict.freetype.ft;
import derelict.openal.al;
import derelict.freeimage.freeimage;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;



extern(C) void processMouse(double xpos, double ypos) nothrow
{
    //if (firstMouse)
    //{
        lastX = xpos;
        lastY = ypos;
        //firstMouse = false;
    //}

    GLfloat xoffset = xpos - lastX;
    GLfloat yoffset = lastY - ypos;  // Reversed since y-coordinates go from bottom to left

    lastX = xpos;
    lastY = ypos;

    camera.ProcessMouseMovement(xoffset, yoffset);
}


void do_movement(Event event)
{
    // Camera controls
    GLfloat magnify = 10; 	
    //if (keys[GLFW_KEY_W])
	
    if (event.keyboard.key == Key.w)	
        camera.ProcessKeyboard(Camera_Movement.FORWARD, (deltaTime * magnify));
    if (event.keyboard.key == Key.s)
        camera.ProcessKeyboard(Camera_Movement.BACKWARD, (deltaTime * magnify));
    if (event.keyboard.key == Key.a)
        camera.ProcessKeyboard(Camera_Movement.LEFT, (deltaTime * magnify));
    if (event.keyboard.key == Key.d)
        camera.ProcessKeyboard(Camera_Movement.RIGHT, (deltaTime * magnify));
    
}
void moveCamera(Event event)
{
 /+   
    // Camera controls
    GLfloat cameraSpeed = 0.01;

    if (event.keyboard.key == Key.w)
	{
        cameraPos += cameraSpeed * cameraFront;
		writeln("W key pressed cameraPos = ", cameraPos);
    }
    if (event.keyboard.key == Key.s)
    {
        cameraPos -= cameraSpeed * cameraFront;
   		writeln("S key pressed cameraPos = ", cameraPos);
    }     
    if (event.keyboard.key == Key.a)
    {
        cameraPos -= cross(cameraFront, cameraUp).normalized * cameraSpeed;
        writeln("A key pressed cameraPos = ", cameraPos);
    }
    if (event.keyboard.key == Key.d)
    {
        cameraPos += cross(cameraFront, cameraUp).normalized * cameraSpeed;
        writeln("D key pressed cameraPos = ", cameraPos);
    }
+/	
}



extern(C) void onWindowResize(GLFWwindow* window, int width, int height) nothrow
{
    glfwSetWindowSize(window, width, height);   
    glViewport(0, 0, width, height);
	//writeln("Inside onWindowResize");
}


extern(C) void cursor_enter_leave_callback(GLFWwindow* window, int entered) nothrow
{
    if (entered)
    {
        // The cursor entered the client area of the window
        //globalCameraPos   = cameraPos;
        //globalCameraFront = cameraFront;
        //globalCameraUp    = cameraUp;		
    }
    else
    {
        // The cursor left the client area of the window
    }
}
 
// Window dimensions
const GLuint width = 800, height = 600;


Camera camera;  // C++ had: Camera  camera(glm::vec3(0.0f, 0.0f, 3.0f)); here
GLfloat lastX =  width / 2.0;
GLfloat lastY =  height / 2.0;

// Light attributes
vec3 lightPos = vec3(1.2f, 1.0f, 2.0f);

// Deltatime
GLfloat deltaTime = 0.0f;	// Time between current frame and last frame
GLfloat lastFrame = 0.0f;  	// Time of last frame

bool firstMouse = true;

void main(string[] argv)
{
    // Camera
    camera = new Camera(vec3(0.0f, 0.0f, 3.0f));            //////////////////////////  ORIGINALLY 3.0

    //auto winMain = load_libraries();
	load_libraries();
	
	auto winMain = glfwCreateWindow(800, 600, "02_01_lighting_colors", null, null);
	
	glfwMakeContextCurrent(winMain); 
 
    // you must set the callbacks after creating the window
 
            glfwSetKeyCallback(winMain, &onKeyEvent);
      glfwSetCursorPosCallback(winMain, &onCursorPosition);
     glfwSetWindowSizeCallback(winMain, &onWindowResize);
    glfwSetCursorEnterCallback(winMain, &onCursorEnterLeave);  // triggered when cursor enters or leaves the window

    Shader[] lightingShaders =
    [
        Shader(GL_VERTEX_SHADER,   "source/LightingVertexShader.glsl",   0),
        Shader(GL_FRAGMENT_SHADER, "source/LightingFragmentShader.glsl", 0)
    ];
    GLuint lightingShader = createProgramFromShaders(lightingShaders);

    Shader[] lampShaders =
    [
        Shader(GL_VERTEX_SHADER,   "source/LampVertexShader.glsl",   0),
        Shader(GL_FRAGMENT_SHADER, "source/LampFragmentShader.glsl", 0)
    ];
    GLuint lampShader = createProgramFromShaders(lampShaders);

    writeln("lightingShader = ", lightingShader);
    writeln("lampShader = ", lampShader);

	// Define the viewport dimensions
    glViewport(0, 0, width, height);
	
    // OpenGL options
    glEnable(GL_DEPTH_TEST);	
	

    // Set up vertex data (and buffer(s)) and attribute pointers
    GLfloat[] vertices;
	initializeCubeJustPositions(vertices);
	
    writeln("vertices = ", vertices);

    // World space positions of our cubes
    //vec3[] cubePositions;
    //initializeCubePositions(cubePositions);
 
    GLuint VBO, VAO;
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.arraySizeInBytes, vertices.ptr, GL_STATIC_DRAW);

    glBindVertexArray(VAO);
    // Position attribute    Data         Stride                        offset
    //                       len
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * GLfloat.sizeof, cast(const(void)*) 0);
    glEnableVertexAttribArray(0);
    glBindVertexArray(0);   // Unbind VAO

    // Then, we set the light's VAO (VBO stays the same. After all, the vertices are the same for 
    // the light object (also a 3D cube))
    GLuint lightVAO;
    glGenVertexArrays(1, &lightVAO);
    glBindVertexArray(lightVAO);
    // We only need to bind to the VBO (to link it with glVertexAttribPointer), no need 
    // to fill it; the VBO's data already contains all we need.
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    // Set the vertex attributes (only position data for the lamp))
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * GLfloat.sizeof, cast(const(void)*) 0);
    glEnableVertexAttribArray(0);
    glBindVertexArray(0);

    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        // Calculate delta time of current frame
        GLfloat currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;
		
        //writeln("deltaTime = ", deltaTime);

        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions 

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
            if (event.type == EventType.cursorEnterLeave)
            {			
                //enableCursor(event);
            }
            if (event.type == EventType.cursorPosition)
            {			
                processMouse(event.cursor.position.x, event.cursor.position.y);
            }							
        }						   
						   


        // Clear the colorbuffer
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	    // Use cooresponding shader when setting uniforms/drawing objects
        glUseProgram(lightingShader);
        GLint objectColorLoc = glGetUniformLocation(lightingShader, "objectColor");
        GLint lightColorLoc  = glGetUniformLocation(lightingShader, "lightColor"); 
        glUniform3f(objectColorLoc, 1.0f, 0.5f, 0.31f);
        glUniform3f(lightColorLoc,  1.0f, 0.5f, 1.0f);

        // Create camera transformations
        mat4 view = mat4.identity;
        view = camera.GetViewMatrix();

        mat4 projection = mat4.identity;
        //GLfloat nonConstCameraZoom = camera.zoom;
        projection = perspectiveFunc(camera.zoom, width/height, 0.1f, 100.0f);
        // Get the uniform locations
        GLint modelLoc = glGetUniformLocation(lightingShader, "model");
        GLint viewLoc  = glGetUniformLocation(lightingShader, "view");
        GLint projLoc  = glGetUniformLocation(lightingShader, "projection");
		
        // Note: currently we set the projection matrix each frame, but since 
        // the projection matrix rarely changes it's often best practice to set 
        // it outside the main loop only once.
		
        // Pass the matrices to the shader
        glUniformMatrix4fv(viewLoc,  1, GL_TRUE, view.value_ptr);
        glUniformMatrix4fv(projLoc,  1, GL_FALSE, projection.value_ptr);


        // Draw the container (using container's vertex attributes)
        glBindVertexArray(VAO);
            mat4 model = mat4.identity;
            glUniformMatrix4fv(modelLoc, 1, GL_TRUE, model.value_ptr);
            glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArray(0);

  
        // Also draw the lamp object, again binding the appropriate shader
        glUseProgram(lampShader);
        // Get location objects for the matrices on the lamp shader (these could be different on a different shader)
        modelLoc = glGetUniformLocation(lampShader, "model");
        viewLoc  = glGetUniformLocation(lampShader, "view");
        projLoc  = glGetUniformLocation(lampShader, "projection");
        // Set matrices
        glUniformMatrix4fv(viewLoc, 1, GL_TRUE, view.value_ptr);
        glUniformMatrix4fv(projLoc, 1, GL_FALSE, projection.value_ptr);
		
        model = mat4.identity;
        model = model.scale(0.2, 0.2, 0.2);   // Make it a smaller cube	
        model = model.translate(lightPos);	  // Swap order of translate/scale???			
 
        glUniformMatrix4fv(modelLoc, 1, GL_TRUE, model.value_ptr);
        // Draw the light object (using light's vertex attributes)
        glBindVertexArray(lightVAO);
            glDrawArrays(GL_TRIANGLES, 0, 36);
        glBindVertexArray(0);

        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
	return;
}


