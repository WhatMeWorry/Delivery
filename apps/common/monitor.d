module monitor;


import bindbc.glfw;
import std.stdio;
import std.conv;
import mytoolbox;
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

void showMonitorProperties(GLFWmonitor* monitor)
{
    /+ Each monitor has a
       - current video mode, 
       - virtual position 
       - human-readable name
       - estimated physical size 
       - gamma ramp
       - list of supported video modes
    +/


    int count;
    const GLFWvidmode* modes = glfwGetVideoModes(monitor, &count);

    for (int i = 0; i < count; i++)
    {
        //modes[i].width 
    }



}



void showAllMonitors()
{
    int count;
    GLFWmonitor** monitors = glfwGetMonitors(&count);

    writeln("");
    writeln("GLFW has detected ", count, " monitors on this system.");
    writeln("---------------------------------------------");
    for (int i = 0; i < count; i++)
    {  
        const char* name = glfwGetMonitorName(monitors[i]);
        string dString = to!string(name);        
        if (i==0)
        {
            writeln("Primary monitor name = ", dString);     
        }
        else
        {
            writeln("monitor name = ", dString);
        }

        int modeCount;
        const GLFWvidmode* modes = glfwGetVideoModes(monitors[i], &modeCount);

        writeln("This monitor has ", modeCount, " video modes");

        for (int j = 0; j < modeCount; j++)
        {
            const GLFWvidmode mode = modes[j];
            writeln("mode.width = ", mode.width, " x ", mode.height, "mode.refreshRate = ", mode.refreshRate);                           
        }

        // The physical size of a monitor in millimetres, or an estimation of it, 
        // can be retrieved with glfwGetMonitorPhysicalSize. This has no relation 
        // to its current resolution, i.e. the width and height of its current video mode.

        int widthMM, heightMM;
        float mmToInch = 0.0393701;

        glfwGetMonitorPhysicalSize(monitors[i], &widthMM, &heightMM);
        writeln("Physical width of monitor is ", widthMM, " millimeters or ", (widthMM * mmToInch), " inches");
        writeln("Physical height of monitor is ", heightMM, " millimeters or ", (heightMM * mmToInch), " inches");   

        const GLFWvidmode* mode = glfwGetVideoMode(monitors[i]);
        //The resolution of a video mode is specified in screen coordinates, not pixels.
    
        writeln("width in Screen coordinates of monitor = ", mode.width);
        writeln("Height in Screen coordinates of monitor = ", mode.height);
    
        writeln("Red   Bits of monitor = ", mode.redBits);
        writeln("Green Bits of monitor = ", mode.greenBits);
        writeln("Blue  Bits of monitor = ", mode.blueBits);

        writeln("Refresh rate of monitor = ", mode.refreshRate, "Hz");

        float inchesToMillimeters = 25.4;
        double dpi = mode.width / (widthMM / inchesToMillimeters);
        writeln("dots per inch = ", dpi);         

        int virtualPosX, virtualPosY;
        glfwGetMonitorPos(monitors[i], &virtualPosX, &virtualPosY);
        writeln("X position of monitor on virtual desktop in screen coordinates = ", virtualPosX);
        writeln("Y position of monitor on virtual desktop in screen coordinates = ", virtualPosY);  

        const GLFWgammaramp* ramp = glfwGetGammaRamp(monitors[i]);
        writeln("ramp.size = ", ramp.size);
        writeln("ramp.red = ",  *ramp.red);
        writeln("ramp.green = ", *ramp.green);
        writeln("ramp.blue = ", *ramp.blue);

        writeln("");
    }
    writeln("");    

    GLFWmonitor* primaryMonitor = glfwGetPrimaryMonitor();
    const char* name = glfwGetMonitorName(primaryMonitor);
    string dString = to!string(name);
    //writeln("Primary monitor name = ", dString);
    GLFWmonitor* mon = monitors[1];
    const char* name1 = glfwGetMonitorName(mon); 
    dString = to!string(name1);
    //writeln("Primary monitor name = ", dString);   


    // The physical size of a monitor in millimetres, or an estimation of it, 
    // can be retrieved with glfwGetMonitorPhysicalSize. This has no relation 
    // to its current resolution, i.e. the width and height of its current video mode.

    int widthMM, heightMM;
    glfwGetMonitorPhysicalSize(primaryMonitor, &widthMM, &heightMM);
    writeln("Physical width size of monitor in millimeters = ", widthMM);
    writeln("Physical height size of monitor in millimeters = ", heightMM);   

    // This can, for example, be used together with the current video mode to calculate the DPI of a monitor.

    const GLFWvidmode* mode = glfwGetVideoMode(primaryMonitor);

    const double dpi = mode.width / (widthMM / 25.4);
    writeln("dots per inch = ", dpi); 

    //writeAndPause(" ");
}



void showMonitorVideoMode()
{
    GLFWmonitor* primaryMonitor = glfwGetPrimaryMonitor();

    //GLFWvidmode videoMode = 
    const GLFWvidmode* mode = glfwGetVideoMode(primaryMonitor);
    //The resolution of a video mode is specified in screen coordinates, not pixels.
    

    writeln("width in Screen coordinates of monitor = ", mode.width);
    writeln("Height in Screen coordinates of monitor = ", mode.height);
    
    writeln("Red   Bits of monitor = ", mode.redBits);
    writeln("Green Bits of monitor = ", mode.greenBits);
    writeln("Blue  Bits of monitor = ", mode.blueBits);

    writeln("Refresh rate of monitor = ", mode.refreshRate, "Hz");

    int virtualPosX, virtualPosY;
    glfwGetMonitorPos(primaryMonitor, &virtualPosX, &virtualPosY);
    writeln("X position of monitor on virtual desktop in screen coordinates = ", virtualPosX);
    writeln("Y position of monitor on virtual desktop in screen coordinates = ", virtualPosY);  

}




