module timer;

import bindbc.glfw;
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
struct AutoRestartTimer 
{
    double  duration = 0.0;
    double  startTime = 0.0;
    double  endTime = 0.0;
    void setDuration(double inSecs)
    {
        duration = inSecs;
    }
    void startTimer()
    {
        endTime = glfwGetTime() + duration;
    }
    bool expires()
    {
        double currentTime = glfwGetTime();
        if (glfwGetTime() > endTime)
        {
            startTimer();  // restart timer
            return true;
        }
        return false;
    }
}


struct ManualTimer    // Have to restart the timer manually; call startTimer explicitly
{                     // after each timer expiry
    double  startTime = 0.0;
    double  endTime = 0.0;
    void startTimer(double durationInSecs)
    {
        endTime = glfwGetTime() + durationInSecs;
    }
    bool expires()
    {
        //writeln("within expires");
        if (glfwGetTime() > endTime)
        {
            return true;
        }
        return false;
    }

}


