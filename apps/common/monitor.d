module monitor;

import derelict.glfw3.glfw3;
import std.stdio;

//import mytoolbox;    // toRadians

// Std. Includes
//#include <vector>

// GL Includes
//#include <GL/glew.h>
//#include <glm/glm.hpp>
//#include <glm/gtc/matrix_transform.hpp>


// Defines several possible options for camera movement. Used as abstraction 
// to stay away from window-system specific input methods
/+
enum Camera_Movement 
{
    FORWARD,
    BACKWARD,
    LEFT,
    RIGHT
};
+/

void showMonitorVideoMode()
{
    GLFWmonitor* primeMonitor = glfwGetPrimaryMonitor();	
	
    //GLFWvidmode videoMode = 
    const GLFWvidmode* mode = glfwGetVideoMode(primeMonitor);
    //The resolution of a video mode is specified in screen coordinates, not pixels.
       	
    writeln("width in Screen coordinates of monitor = ", mode.width);
		
	writeln("Height in Screen coordinates of monitor = ", mode.height);
	
    writeln("Refresh rate of monitor = ", mode.refreshRate, "Hz");

    int virtualPosX, virtualPosY;
    glfwGetMonitorPos(primeMonitor, &virtualPosX, &virtualPosY);
    writeln("X position of monitor on virtual desktop in screen coordinates = ", virtualPosX);
    writeln("Y position of monitor on virtual desktop in screen coordinates = ", virtualPosY);  
	
}




