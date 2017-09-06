module camera;

import gl3n.linalg;  // vec3, cross(), look_at()
import derelict.opengl3.gl3; // GLfloat
import mytoolbox;    // toRadians
import std.stdio;    // writeln
import std.math;     // sin  cos
/+
// Defines several possible options for camera movement. Used as abstraction 
// to stay away from window-system specific input methods
enum Camera_Movement 
{
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT
};

// Default camera values
const GLfloat YAW         = -90.0f;
const GLfloat PITCH       =   0.0f;
const GLfloat SPEED       =   1.0f;  // original .01 value was way too slow!
const GLfloat SENSITIVITY =   0.25f; // originally value was 0.025
const GLfloat ZOOM        =  45.0f;

string globalString;
int iGlobal = 0;
int jGlobal = 0;
float gXoffset = 0;
float gYoffset = 0;
float gOffsetY = 0;
float lastOffset = 0;
vec3 globalVec3 = vec3(0.0f, 0.0f, 0.0f);
vec3 lastGlobalVec3 = vec3(0.0f, 0.0f, 0.0f);

float gYaw = 0.0f;
float gPitch = 0.0f;
float lastYaw = 0.0f;
float lastPitch = 0.0f;


// You can't have a variable with the same name as a module because 
// they're both symbols with the same name. It messes up the symbol
// resolution code. (Also, it confuses any programmer who reads your code)

// An abstract camera class that processes input and calculates the   
// corresponding Eular Angles, Vectors and Matrices for use in OpenGL
class Camera
{
public:
    // Camera Attributes
    vec3 position = vec3(0.0f, 0.0f, 0.0f);
    vec3 front = vec3(0.0f, 0.0f, -1.0f);
    vec3 up = vec3(0.0f, 1.0f, 0.0f);
    vec3 right;
    vec3 worldUp;
    // Eular Angles
    GLfloat yaw = YAW;
    GLfloat pitch = PITCH;
    // Camera options
    GLfloat movementSpeed = SPEED;
    GLfloat mouseSensitivity = SENSITIVITY;
    GLfloat zoom = ZOOM;

    // Constructor with vectors  ..Added this to match C++ code invocation
    this(vec3 position)                 
    {
        this.position = position;
        this.front = vec3(0.0f, 0.0f, -1.0f);
        this.up = vec3(0.0f, 1.0f, 0.0f);
        this.worldUp = up;
        this.updateCameraVectors();
        this.yaw = YAW;
        this.pitch = PITCH;
        // Camera options
        this.movementSpeed = SPEED;
        this.mouseSensitivity = SENSITIVITY;
        this.zoom = ZOOM;
    }
    // Constructor with vectors
    this(vec3 position, vec3 up, GLfloat yaw, GLfloat pitch)                 
    {
        this.position = position;
        this.worldUp = up;
        this.yaw = yaw;
        this.pitch = pitch;

        this.updateCameraVectors();
    }
    // Constructor with scalar values
    this(GLfloat posX, GLfloat posY, GLfloat posZ, 
         GLfloat upX,  GLfloat upY,  GLfloat upZ, 
         GLfloat yaw,  GLfloat pitch) 
    {
        this.position = vec3(posX, posY, posZ);
        this.worldUp = vec3(upX, upY, upZ);
        this.yaw = yaw;
        this.pitch = pitch;

        this.updateCameraVectors();
    }

    // Returns the view matrix calculated using Eular Angles and the LookAt Matrix
    mat4 GetViewMatrix()
    {
        // definition of look_at starts with:  static if(isFloatingPoint!mt) {...
        //mat4 lookAt = mat4.look_at(this.position, this.position + this.front, this.up);
        return mat4.look_at(this.position, this.position + this.front, this.up);
    }


    // Processes input received from any keyboard-like input system. Accepts input parameter 
    // in the form of camera defined ENUM (to abstract it from windowing systems)

    void ProcessKeyboard(Camera_Movement direction, GLfloat deltaTime)
    {
        GLfloat velocity = this.movementSpeed * deltaTime;

        writeln("this.position = ", this.position);

        if (direction == Camera_Movement.FORWARD)
            this.position += this.front * velocity;
        if (direction == Camera_Movement.BACKWARD)
            this.position -= this.front * velocity;
        if (direction == Camera_Movement.LEFT)
            this.position -= this.right * velocity;
        if (direction == Camera_Movement.RIGHT)
            this.position += this.right * velocity;
    }


    // Processes input received from a mouse input system. Expects the offset value in both the x and y direction.
    void ProcessMouseMovement(GLfloat xoffset, GLfloat yoffset, GLboolean constrainPitch = true) nothrow
    {
        xoffset *= this.mouseSensitivity;
        yoffset *= this.mouseSensitivity;

        this.yaw   += xoffset;
        this.pitch += yoffset;

        // Make sure that when pitch is out of bounds, screen doesn't get flipped
        if (constrainPitch)
        {
            if (this.pitch > 89.0f)
                this.pitch = 89.0f;
            if (this.pitch < -89.0f)
                this.pitch = -89.0f;
        }

        // Update Front, Right and Up Vectors using the updated Eular angles
        try
        {
            this.updateCameraVectors();
        }
        catch {}
    }


    // Processes input received from a mouse scroll-wheel event. Only requires input on the vertical wheel-axis
    void ProcessMouseScroll(GLfloat yoffset) nothrow
    {
        gOffsetY = yoffset;
        yoffset = yoffset * .01; 
        if (this.zoom >= 1.0f && this.zoom <= 45.0f)
            this.zoom -= yoffset;
        if (this.zoom <= 1.0f)
            this.zoom = 1.0f;
        if (this.zoom >= 45.0f)
            this.zoom = 45.0f;
    }

private:
    // Calculates the front vector from the Camera's (updated) Eular Angles
    void updateCameraVectors()
    {
        jGlobal++;
        // Calculate the new Front vector
        vec3 front;
        front.x = cos(toRadians(this.yaw)) * cos(toRadians(this.pitch));
        front.y = sin(toRadians(this.pitch));
        front.z = sin(toRadians(this.yaw)) * cos(toRadians(this.pitch));

        globalVec3 = this.front; 

        this.front = this.front.normalized;

        globalVec3 = this.front; 

        // Also re-calculate the Right and Up vector

        // Normalize the vectors, because their length gets closer 
        // to 0 the more you look up or down which results in slower movement.

        //this.right = cross!(vec3)(this.front, this.worldUp).normalized();  
        this.right = cross(this.front, this.worldUp).normalized;

        this.up = cross(this.right, this.front).normalized;
    }
};
+/