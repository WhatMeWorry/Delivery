
module app;  // 02_06_multiple_lights

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
    int pixelWidth, pixelHeight;
    glfwGetFramebufferSize(window, &pixelWidth, &pixelHeight);  
    glViewport(0, 0, pixelWidth, pixelHeight);
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

void main(string[] argv)
{
    camera = new Camera(vec3(0.0f, 0.0f, 3.0f));
 
    load_libraries();
	
    auto winMain = glfwCreateWindow(800, 600, "02_06_multiple_lights", null, null);
	
    glfwMakeContextCurrent(winMain); 
	
    // you must set the callbacks after creating the window
	   
     glfwSetCursorPosCallback(winMain, &mouse_callback); 
           glfwSetKeyCallback(winMain, &onInternalKeyEvent);
        glfwSetScrollCallback(winMain, &mouseScrollWheel_callback);
    glfwSetWindowSizeCallback(winMain, &onWindowResize);
	 
    // Define the viewport dimensions
    glViewport(0, 0, width, height);

    // Setup OpenGL options
    glEnable(GL_DEPTH_TEST);


    Shader[] lightingShaders =
    [
          Shader(GL_VERTEX_SHADER, "source/MultipleLightsVertexShader.glsl",   0),
        Shader(GL_FRAGMENT_SHADER, "source/MultipleLightsFragmentShader.glsl", 0)
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
	
    // World space positions of our cubes
    vec3[] cubePositions = 
    [
        vec3( 0.0f,  0.0f,  0.0f),
        vec3( 2.0f,  5.0f, -15.0f),
        vec3(-1.5f, -2.2f, -2.5f),
        vec3(-3.8f, -2.0f, -12.3f),
        vec3( 2.4f, -0.4f, -3.5f),
        vec3(-1.7f,  3.0f, -7.5f),
        vec3( 1.3f, -2.0f, -2.5f),
        vec3( 1.5f,  2.0f, -2.5f),
        vec3( 1.5f,  0.2f, -1.5f),
        vec3(-1.3f,  1.0f, -1.5f)
    ];

    // Positions of the point lights
    vec3[] pointLightPositions = 
    [
        vec3( 0.7f,  0.2f,  2.0f),
        vec3( 2.3f, -3.3f, -4.0f),
        vec3(-4.0f,  2.0f, -12.0f),
        vec3( 0.0f,  0.0f, -3.0f)
    ];	

    GLuint VBO, containerVAO;
    glGenVertexArrays(1, &containerVAO);
    glGenBuffers(1, &VBO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, vertices.arraySizeInBytes, vertices.ptr, GL_STATIC_DRAW);

    glBindVertexArray(containerVAO);

    mixin( defineVertexLayout!(int)([3,3,2]) );
    pragma( msg, defineVertexLayout!(int)([3,3,2]) );        
    // Position attribute    Data         Stride                        offset
    //                       len
    //glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) 0);
    //glEnableVertexAttribArray(0);
    //glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (3*GLfloat.sizeof) );
    //glEnableVertexAttribArray(1);
    //glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * GLfloat.sizeof, cast(const(void)*) (6*GLfloat.sizeof) );
    //glEnableVertexAttribArray(2);
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

    // Load textures
    GLuint diffuseMap;
    GLuint specularMap; 

    glGenTextures(1, &diffuseMap);
    glGenTextures(1, &specularMap);

    loadTexture(diffuseMap,  "../art/container2.png");          // relative to executable) 
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

        // Clear the colorbuffer
        glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


        // Use cooresponding shader when setting uniforms/drawing objects
        glUseProgram(lightingShader);
        GLint viewPosLoc = glGetUniformLocation(lightingShader, "viewPos");
        glUniform3f(viewPosLoc, camera.position.x, camera.position.y, camera.position.z);
        // Set material properties
        glUniform1f(glGetUniformLocation(lightingShader, "material.shininess"), 32.0f);
        // == ==========================
        // Here we set all the uniforms for the 5/6 types of lights we have. We have to set them manually and index 
        // the proper PointLight struct in the array to set each uniform variable. This can be done more code-friendly
        // by defining light types as classes and set their values in there, or by using a more efficient uniform approach
        // by using 'Uniform buffer objects', but that is something we discuss in the 'Advanced GLSL' tutorial.
        // == ==========================
        // Directional light
        glUniform3f(glGetUniformLocation(lightingShader, "dirLight.direction"), -0.2f, -1.0f, -0.3f);
        glUniform3f(glGetUniformLocation(lightingShader, "dirLight.ambient"), 0.05f, 0.05f, 0.05f);
        glUniform3f(glGetUniformLocation(lightingShader, "dirLight.diffuse"), 0.4f, 0.4f, 0.4f);
        glUniform3f(glGetUniformLocation(lightingShader, "dirLight.specular"), 0.5f, 0.5f, 0.5f);
        // Point light 1
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[0].position"), 
		                                                  pointLightPositions[0].x, 
														  pointLightPositions[0].y, 
														  pointLightPositions[0].z);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[0].ambient"), 0.05f, 0.05f, 0.05f);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[0].diffuse"), 0.8f, 0.8f, 0.8f);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[0].specular"), 1.0f, 1.0f, 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[0].constant"), 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[0].linear"), 0.09);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[0].quadratic"), 0.032);
        // Point light 2
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[1].position"), 
		                                                  pointLightPositions[1].x, 
                                                          pointLightPositions[1].y, 
                                                          pointLightPositions[1].z);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[1].ambient"), 0.05f, 0.05f, 0.05f);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[1].diffuse"), 0.8f, 0.8f, 0.8f);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[1].specular"), 1.0f, 1.0f, 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[1].constant"), 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[1].linear"), 0.09);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[1].quadratic"), 0.032);
        // Point light 3
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[2].position"), 
                                                          pointLightPositions[2].x, 
                                                          pointLightPositions[2].y, 
                                                          pointLightPositions[2].z);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[2].ambient"), 0.05f, 0.05f, 0.05f);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[2].diffuse"), 0.8f, 0.8f, 0.8f);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[2].specular"), 1.0f, 1.0f, 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[2].constant"), 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[2].linear"), 0.09);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[2].quadratic"), 0.032);
        // Point light 4
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[3].position"), 
                                                          pointLightPositions[3].x, 
                                                          pointLightPositions[3].y, 
                                                          pointLightPositions[3].z);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[3].ambient"), 0.05f, 0.05f, 0.05f);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[3].diffuse"), 0.8f, 0.8f, 0.8f);
        glUniform3f(glGetUniformLocation(lightingShader, "pointLights[3].specular"), 1.0f, 1.0f, 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[3].constant"), 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[3].linear"), 0.09);
        glUniform1f(glGetUniformLocation(lightingShader, "pointLights[3].quadratic"), 0.032);
        // SpotLight
        glUniform3f(glGetUniformLocation(lightingShader, "spotLight.position"), 
                                                          camera.position.x, 
                                                          camera.position.y, 
                                                          camera.position.z);
        glUniform3f(glGetUniformLocation(lightingShader, "spotLight.direction"), 
                                                          camera.front.x, 
                                                          camera.front.y, 
                                                          camera.front.z);
        glUniform3f(glGetUniformLocation(lightingShader, "spotLight.ambient"), 0.0f, 0.0f, 0.0f);
        glUniform3f(glGetUniformLocation(lightingShader, "spotLight.diffuse"), 1.0f, 1.0f, 1.0f);
        glUniform3f(glGetUniformLocation(lightingShader, "spotLight.specular"), 1.0f, 1.0f, 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "spotLight.constant"), 1.0f);
        glUniform1f(glGetUniformLocation(lightingShader, "spotLight.linear"), 0.09);
        glUniform1f(glGetUniformLocation(lightingShader, "spotLight.quadratic"), 0.032);
        glUniform1f(glGetUniformLocation(lightingShader, "spotLight.cutOff"), cos(toRadians(12.5f)));
        glUniform1f(glGetUniformLocation(lightingShader, "spotLight.outerCutOff"), cos(toRadians(15.0f)));

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

        glBindVertexArray(containerVAO);
        for (GLuint i = 0; i < 10; i++)
        {

            // Calculate the model matrix for each object and pass it to shader before drawing
            mat4 model = mat4.identity;
            // opposite order as the C++
            GLfloat angle = 1.0f * i;
            model = model.rotate(angle, vec3(1.0f, 0.3f, 0.5f));

            model = model.translate(cubePositions[i]);
            //writeln("model matrix = ", model);
            //GLfloat angle = 20.0f * i;
            //model = model.rotate(angle, vec3(1.0f, 0.3f, 0.5f));
            glUniformMatrix4fv(modelLoc, 1, GL_TRUE, model.value_ptr);

            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
        glBindVertexArray(0);


        glfwSwapBuffers(winMain);   // Swap front and back buffers 
    }

    glfwTerminate();   // Clear any resources allocated by GLFW.
	return;
}


