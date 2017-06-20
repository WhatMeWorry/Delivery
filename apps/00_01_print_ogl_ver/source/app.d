
module app; // 00_01_display_opengl_version

import std.stdio;
import std.conv; //   : to;
import std.string; // : toStringz;
import std.stdio; //  : writeln, writefln;
import derelict.opengl3.gl3;
import derelict.glfw3.glfw3;
import std.process;

/+
There's a specific mapping between OpenGL version and supported GLSL version:

GLSL Version      OpenGL Version
1.10          2.0
1.20          2.1
1.30          3.0
1.40          3.1
1.50          3.2
3.30          3.3
4.00          4.0
4.10          4.1
4.20          4.2
4.30          4.3
4.40          4.4
+/


void main(string[] argv)
{
    DerelictGLFW3.load();

    if (glfwInit() == 0)
        throw new Exception("glfwInit failed");

    DerelictGL3.load();  // loads only the functions for OpenGL versions 1.0 and 1.1

    writeln("DerelictGL3.load execute fine.");

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);   // Lenovo Tiny PCs are at openGL 4.2    Lian Li PC-33B is OpenGL 4.4
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);   // iMac 27" are at opengl 4.1
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);

    // The GLFWwindow object encapsulates both a window and a context. They are created with glfwCreateWindow
    // and destroyed with glfwDestroyWindow (or glfwTerminate, if any remain). As the window and context are
    // inseparably linked, the object pointer is used as both a context and window handle.


    auto window = glfwCreateWindow(800, 600, "Shaders", null, null);
    if(!window)
        throw new Exception("Window Creation Failed.");

    glfwMakeContextCurrent(window);  // required or else following output commands will not work.

    DerelictGL3.reload();  // load versions 1.2+ and all supported ARB and EXT extensions

    //auto ls = executeShell("mode con cols=100 lines=400");

    executeShell("mode con cols=100 lines=400");

    GLint major, minor;
    glGetIntegerv(GL_MAJOR_VERSION, &major);
    glGetIntegerv(GL_MINOR_VERSION, &minor);

    writeln("GL Version (integer): ", major, ".", minor);

    // const GLubyte *version = glGetString(GL_VERSION);  // C++ and openLG code

    // documentatino from std.string shows
    //pure @system inout(char)[] fromStringz(inout(char)* cString);

    // both

    // char openglVersion[100] = to!string(glGetString(GL_VERSION));    // this compiles with no errors or warnings

    // char openglVersion[100] = fromStringz(glGetString(GL_VERSION));  // this compiles with no errors or warnings


    // The OpenGL specification requires strings returned by glGetString to be
    // static, i.e. the pointer will always be valid

    // fromStringz returns a slice of the C string, which means that
    // if the C string doesn't survive after the return call, or if you plan to
    // keep your D string around outside of the call site, you can get a crash.

    // Generally, though, to!string is what you want. It allocates memory for the string and copies it.

    // char vendor[100] = fromStringz(glGetString(GL_VENDOR));  // this compiles with no errors or warnings

    //string vendor = fromStringz(glGetString(GL_VENDOR));   // vendor is a slice of the dynamic-array owned by D's run-time system.
    // cannot implicitly convert expression (fromStringz((*glGetString)(7936u))) of type const(char)[] to string

    //pure @system inout(char)[] fromStringz(inout(char)* cString);

    /+ These all syntaxes work
    const(char)[] vendor = fromStringz(glGetString(GL_VENDOR));

    auto myActualVendorCopy = to!string(glGetString(GL_VENDOR));

    string dynamicCharArray = glGetString(GL_VENDOR).fromStringz.idup;

    immutable(char)[] ImmutableVendor = fromStringz(glGetString(GL_VENDOR)).idup;
    +/


    string renderer      = glGetString(GL_RENDERER).fromStringz.idup;
    string vendor        = glGetString(GL_VENDOR).fromStringz.idup;
    string openglVersion = glGetString(GL_VERSION).fromStringz.idup;
    string glslVersion   = glGetString(GL_SHADING_LANGUAGE_VERSION).fromStringz.idup;

    writeln("renderer ", renderer);
    writeln("vendor ", vendor);
    writeln("openglVersion", openglVersion);
    writeln("glslVersion ", glslVersion);

    GLint nExtensions;
    glGetIntegerv(GL_NUM_EXTENSIONS, &nExtensions);

    string[] extArray;
    for(int i = 0; i < nExtensions; i++)
    {
        extArray ~= glGetStringi(GL_EXTENSIONS, i).fromStringz.idup;
    }


    foreach (i, element; extArray)
    {
        writeln(i, ": ", element);
    }

    writeln("GL Version (integer): ", major, ".", minor);
    writeln("renderer ", renderer);
    writeln("vendor ", vendor);
    writeln("openglVersion ", openglVersion);
    writeln("glslVersion ", glslVersion);

    glfwDestroyWindow(window); // The window contest is only need for the .reload() funcion.

    executeShell("pause");
}
