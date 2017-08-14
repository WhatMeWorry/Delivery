
module app;  // 02_04_lighting_maps

import common;

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

// This just declares a pointer to CameraClass that is set to null.  NOTHING ELSE.
Camera camera;  



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


extern(C) void mouse_callback(GLFWwindow* window, double xpos, double ypos) nothrow
{
    if (firstMouse)
    {
        lastX = xpos;
        lastY = ypos;
        firstMouse = false;
    }

    GLfloat xoffset = xpos - lastX;
    GLfloat yoffset = lastY - ypos;  // Reversed since y-coordinates go from bottom to left

    lastX = xpos;
    lastY = ypos;

    camera.ProcessMouseMovement(xoffset, yoffset);
}

extern(C) void mouseScrollWheel_callback(GLFWwindow* window, double xoffset, double yoffset) nothrow
{
    camera.ProcessMouseScrollWheel(yoffset);
}

void do_movement()
{
    // Camera controls
    if (keys[GLFW_KEY_W])
        camera.ProcessKeyboard(Camera_Movement.FORWARD, deltaTime);
    if (keys[GLFW_KEY_S])
        camera.ProcessKeyboard(Camera_Movement.BACKWARD, deltaTime);
    if (keys[GLFW_KEY_A])
        camera.ProcessKeyboard(Camera_Movement.LEFT, deltaTime);
    if (keys[GLFW_KEY_D])
        camera.ProcessKeyboard(Camera_Movement.RIGHT, deltaTime);
}


extern(C) void onWindowResize(GLFWwindow* window, int width, int height) nothrow
{
    //glfwSetWindowSize(window, width, height);
    //glViewport(0, 0, width, height);
    int pixelWidth, pixelHeight;
    glfwGetFramebufferSize(window, &pixelWidth, &pixelHeight);  
    glViewport(0, 0, pixelWidth, pixelHeight);
}


// Window dimensions
const GLuint width = 800, height = 600;



GLfloat lastX =  width / 2.0;
GLfloat lastY =  height / 2.0;
bool[1024] keys;

// Light attributes
vec3 lightPos = vec3(1.2f, 1.0f, 2.0f);

// Deltatime
GLfloat deltaTime = 0.0f;	// Time between current frame and last frame
GLfloat lastFrame = 0.0f;  	// Time of last frame

void main(string[] argv)
{
    camera = new Camera(vec3(0.0f, 0.0f, 3.0f));
 
    load_libraries();
	
    auto winMain = glfwCreateWindow(800, 600, "02_04_lighting_maps", null, null);
	
    glfwMakeContextCurrent(winMain); 
	
    // you must set the callbacks after creating the window
	   
      glfwSetCursorPosCallback(winMain, &mouse_callback); 
            glfwSetKeyCallback(winMain, &onInternalKeyEvent);
         glfwSetScrollCallback(winMain, &mouseScrollWheel_callback);
     glfwSetWindowSizeCallback(winMain, &onWindowResize);
glfwSetFramebufferSizeCallback(winMain, &onFrameBufferResize);    

    // Setup OpenGL options
    glEnable(GL_DEPTH_TEST);


    Shader[] lightingShaders =
    [
          Shader(GL_VERTEX_SHADER, "source/LightingMapsVertexShader.glsl",   0),
        Shader(GL_FRAGMENT_SHADER, "source/LightingMapsFragmentShader.glsl", 0)
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
	
    // Set up vertex data (and buffer(s)) and attribute pointers
    GLfloat[] vertices;
    initializeCubePosNormsTexs(vertices);   //////////////////////// NEW
    writeln("vertices = ", vertices);	
	
    GLuint VBO, containerVAO;
    glGenVertexArrays(1, &containerVAO);
    glGenBuffers(1, &VBO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.arraySizeInBytes, vertices.ptr, GL_STATIC_DRAW);

    glBindVertexArray(containerVAO);
    // Position attribute    Data         Stride                        offset
    //                       len
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) 0);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (3*GLfloat.sizeof) );
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (6*GLfloat.sizeof) );
    glEnableVertexAttribArray(2);
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
    // Note that we skip over the normal vectors
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) 0);
    glEnableVertexAttribArray(0);
    glBindVertexArray(0);

    // Load textures                  ////////////////////////////// NEW
    GLuint diffuseMap;
    GLuint specularMap; 

    glGenTextures(1, &diffuseMap);
    glGenTextures(1, &specularMap);

    loadTexture(diffuseMap,  "../art/container2.png");     // relative to executable
    loadTexture(specularMap, "../art/container2_specular.png");

    // Set texture units
    glUseProgram(lightingShader);
    glUniform1i(glGetUniformLocation(lightingShader, "material.diffuse"),  0);
    glUniform1i(glGetUniformLocation(lightingShader, "material.specular"), 1);
	
	
    while (!glfwWindowShouldClose(winMain))    // Loop until the user closes the window
    {
        // Calculate deltatime of current frame
        GLfloat currentFrame = glfwGetTime();
        deltaTime = currentFrame - lastFrame;
        lastFrame = currentFrame;

        glfwPollEvents();  // Check if any events have been activiated (key pressed, mouse
                           // moved etc.) and call corresponding response functions 
        do_movement();

        handleEvent(winMain);

        // Clear the colorbuffer
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // Use cooresponding shader when setting uniforms/drawing objects
        glUseProgram(lightingShader);
        GLint lightPosLoc = glGetUniformLocation(lightingShader, "light.position");
        GLint viewPosLoc  = glGetUniformLocation(lightingShader, "viewPos");
        glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z);
        glUniform3f(viewPosLoc, camera.position.x, camera.position.y, camera.position.z);

        // Set lights properties
        glUniform3f(glGetUniformLocation(lightingShader, "light.ambient"),  0.2f, 0.2f, 0.2f);
        glUniform3f(glGetUniformLocation(lightingShader, "light.diffuse"),  0.5f, 0.5f, 0.5f);
        glUniform3f(glGetUniformLocation(lightingShader, "light.specular"), 1.0f, 1.0f, 1.0f);
        // Set material properties
        glUniform1f(glGetUniformLocation(lightingShader, "material.shininess"), 32.0f);

        // Create camera transformations
        //mat4 view;  // moved to module level
        mat4 view = mat4.identity;
        view = camera.GetViewMatrix();


        mat4 projection = mat4.identity;
        projection = perspectiveFunc(camera.zoom, width/height, 0.1f, 100.0f);


        // Get their uniform location
        GLint modelLoc = glGetUniformLocation(lampShader, "model");
        GLint viewLoc  = glGetUniformLocation(lampShader, "view");
        GLint projLoc  = glGetUniformLocation(lampShader, "projection");
        // Pass the matrices to the shader
        glUniformMatrix4fv(viewLoc,  1, GL_TRUE, view.value_ptr);
        glUniformMatrix4fv(projLoc,  1, GL_FALSE, projection.value_ptr);

        // Bind diffuse map
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, diffuseMap);
        // Bind specular map
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, specularMap);

        // Draw the container (using container's vertex attributes)
        glBindVertexArray(containerVAO);
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
        model = model.scale(0.2f, 0.2, 0.2); // Make it a smaller cube
        model = model.translate(lightPos);
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